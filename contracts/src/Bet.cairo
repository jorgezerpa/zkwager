// TO DO -> How to manage the remaining of currency? (example -> no perfect 0 divisions, sum of percentages of distributions is not 100, etc)
#[starknet::interface]
pub trait IBet<TContractState> {
    fn init_bet(ref self: TContractState);
    fn fund_bet(ref self: TContractState, player:starknet::ContractAddress);

    fn get_players(ref self: TContractState)-> Array<starknet::ContractAddress>;
    fn get_bet_metadata(ref self: TContractState) -> Bet::Metadata;

    fn check_funders(ref self: TContractState);
    fn cancel_bet(ref self: TContractState);
    fn start_bet(ref self: TContractState);
    fn end_bet(ref self: TContractState);
    fn set_winner(ref self: TContractState);
    fn set_winners(ref self: TContractState);
    fn withdraw_winner(ref self: TContractState);
    fn set_winners_in_counter_mode(ref self: TContractState);
    // -----
    fn get_counter_address_by_id(ref self: TContractState);
    fn get_counter_address_by_name(ref self: TContractState);
    
    fn get_bet_balance(self: @TContractState) -> u256;
}



#[starknet::contract]
mod Bet {
    use starknet::storage::MutableVecTrait;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use starknet::storage::{
        Map, 
        StoragePathEntry,
        // StorageMapReadAccess, StorageMapWriteAccess, 
        StoragePointerReadAccess,
        StoragePointerWriteAccess, 
        Vec, 
        // VecTrait
    };
    use openzeppelin_token::erc20::interface::{ IERC20Dispatcher, IERC20DispatcherTrait };


    #[derive(Serde,Drop)]
    pub struct Metadata {
        pub players: Array<ContractAddress>,
        pub amount_per_player: u128,
        pub total_amount: u128,
        pub number_of_winners: u128, 
        pub percentage_of_distribution: Array<u128>, 
        pub distributions: Array<u128>,
        pub percentage_of_house_hold: u128, 
        pub house_hold: u128, 
        pub fixed_house_hold: u128,
        pub is_bet_running: bool, 
        // has_counters: bool,
        // counters: Vec<CounterMetadata>, // units counted by every user (only used on counter mode)
    }

    #[derive(Serde, Drop)]
    struct CounterMetadata {
        id: u128,
        name: ByteArray,
        counter_address: ContractAddress
    }

    
    #[storage]
    struct Storage {
        // basic
        players: Vec<ContractAddress>,
        players_state: Map<ContractAddress, bool>, // Register of players who deposit the bet calling the fund_bet function
        amount_per_player: u128,
        total_amount: u128,
        number_of_winners: u128, // 1: singleWinner mode, >2: MultiWinner mode
        
        percentage_of_distribution: Vec<u128>, // percentage of how much will gain any player
        distributions: Vec<u128>, // Real value in currency. Calculated by taking the percentage_of_distribution correspondant to positions and number of winners
        percentage_of_house_hold: u128, 
        house_hold: u128, 
        fixed_house_hold: u128,

        winners: Vec<ContractAddress>, // In order, first position, second position... until length match number_of_winners
        is_bet_running: bool, // false by default, set to true when all players agree the bet, if it`s true, functions like withdraw are disabled
        players_agreement: Map<ContractAddress, bool>, // each user has to be agree with the bet before run the bet,

        has_counters: bool,
        counters: Vec<CounterMetadata>, // units counted by every user (only used on counter mode)
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        players: Array<ContractAddress>,
        amount_per_player: u128,
        percentage_of_distribution: Array<u128>,
        percentage_of_house_hold: u128,
        fixed_house_hold:u128,
        // number_of_counters: Array<CounterMetadata>,
    ) {
        for percentage in percentage_of_distribution.clone() {
            assert(percentage>0, 'some percentages are 0');
        };
        let mut sum_of_distribution_percentages = 0_u128;
        for percentage in percentage_of_distribution.clone() {
            sum_of_distribution_percentages += percentage;
        };
        assert(sum_of_distribution_percentages<=100, 'sum is greater than 100');
        // // -----------------

        for player in players.clone() {
            self.players.append().write(player);
            self.players_state.entry(player).write(false);
        };
        for percentage in percentage_of_distribution.clone() {
            self.percentage_of_distribution.append().write(percentage);
        };

        let mut total_amount = BetInternalImpl::calculate_total_amount(amount_per_player, players.len().into(), percentage_of_house_hold, fixed_house_hold );

        for element in BetInternalImpl::calculate_prizes_distribution(total_amount, @percentage_of_distribution) {
            self.distributions.append().write(element);
        };

        self.total_amount.write(total_amount);
        self.amount_per_player.write(amount_per_player);
        self.percentage_of_house_hold.write(percentage_of_house_hold);
        self.house_hold.write(BetInternalImpl::calculate_house_hold(amount_per_player, players.len().into(), percentage_of_house_hold, fixed_house_hold));
        self.number_of_winners.write(percentage_of_distribution.len().into());
        
        
        // // to do -> Syscall to deploy each one of the counters and store it's addresses

    }

    #[abi(embed_v0)]
    impl BetImpl of super::IBet<ContractState> {
        fn init_bet(ref self: ContractState) {}
        fn fund_bet(ref self: ContractState, player:ContractAddress) {
            let erc20_dispatcher = BetInternalImpl::token_dispatcher();

            let recipient = get_contract_address();
            let amount = self.amount_per_player.read();
            erc20_dispatcher.transfer_from(player, recipient, amount.into());
        }
        fn get_players(ref self: ContractState) -> Array<starknet::ContractAddress> {
            let mut players_array = array![];
            let players_vec = self.players;
            for i in 0..players_vec.len() {
                players_array.append(players_vec.at(i).read());
            };
            players_array
        }
        fn get_bet_metadata(ref self: ContractState) -> Metadata {
            let mut players_array = array![];
            let players_vec = self.players;
            for i in 0..players_vec.len() {
                players_array.append(players_vec.at(i).read());
            };
            
            let mut percentage_of_distribution_array = array![];
            let percentage_of_distribution_vec = self.percentage_of_distribution;
            for i in 0..percentage_of_distribution_vec.len() {
                percentage_of_distribution_array.append(percentage_of_distribution_vec.at(i).read());
            };

            let mut distributions_array = array![];
            let distributions_vec = self.distributions;
            for i in 0..distributions_vec.len() {
                distributions_array.append(distributions_vec.at(i).read());
            };

            let currentMetadata = Metadata {
                players: players_array,
                amount_per_player: self.amount_per_player.read(),
                total_amount: self.total_amount.read(),
                number_of_winners: self.percentage_of_distribution.len().into(),
                percentage_of_distribution: percentage_of_distribution_array,
                distributions: distributions_array,
                percentage_of_house_hold: self.percentage_of_house_hold.read(),
                house_hold: self.house_hold.read(),
                fixed_house_hold: self.fixed_house_hold.read(),
                is_bet_running: self.is_bet_running.read(),
            };

            currentMetadata
        }
        fn check_funders(ref self: ContractState) {}
        fn cancel_bet(ref self: ContractState) {}
        fn start_bet(ref self: ContractState) {}
        fn set_winner(ref self: ContractState) {}
        fn set_winners(ref self: ContractState) {}
        fn end_bet(ref self: ContractState) {}
        fn withdraw_winner(ref self: ContractState) {}
        fn set_winners_in_counter_mode(ref self: ContractState) {}
        // -----
        fn get_counter_address_by_id(ref self: ContractState) {}
        fn get_counter_address_by_name(ref self: ContractState) {}
        fn get_bet_balance(self: @ContractState) -> u256 {
            let contract_address = get_contract_address();
            let contract_balance = BetInternalImpl::token_dispatcher().balance_of(contract_address);
            contract_balance
        }
    }
 
    #[generate_trait]
    impl BetInternalImpl of IBetInternal {
        // IMPORTANT -> ask how to manage mode of division 
        // Solution 1: Division always "round" down. So you can take the sobrant after distribution and add to winner, house, etc
        // Note: module operator % could be usefull here 
        fn calculate_prizes_distribution(total_amount:u128, percentage_of_distribution:@Array<u128>) -> Array<u128> {
            let mut distributions = ArrayTrait::<u128>::new();
            for percentage in percentage_of_distribution.span() {
                let prize = (total_amount * *percentage)/100;
                distributions.append(prize);
            };
            distributions
        }
        fn calculate_total_amount(amount_per_player:u128, number_of_players:u128, percentage_of_house_hold:u128, fixed_house_hold:u128) -> u128 {
            let total_amount = amount_per_player * number_of_players;
            if percentage_of_house_hold==0 {
                return total_amount - fixed_house_hold;
            };
            let house_hold = ((percentage_of_house_hold * total_amount)/100)-fixed_house_hold;
            let real_total_amount = total_amount - house_hold;
            real_total_amount
        }
        fn calculate_house_hold(amount_per_player:u128, number_of_players:u128, percentage_of_house_hold:u128, fixed_house_hold:u128) -> u128 {
            if percentage_of_house_hold==0 {
                return 0;
            };
            let total_amount = amount_per_player * number_of_players;
            let real_total_amount = ((percentage_of_house_hold * total_amount)/100)-fixed_house_hold;
            real_total_amount
        }
        fn token_dispatcher() -> IERC20Dispatcher {
            IERC20Dispatcher {
                contract_address: starknet::contract_address_const::<0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d>()
            }
        }
        
    }


}
