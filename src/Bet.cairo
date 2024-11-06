// TO DO -> How to manage the remaining of currency? (example -> no perfect 0 divisions, sum of percentages of distributions is not 100, etc)

#[starknet::interface]
pub trait IBet<TContractState> {
    fn init_bet(ref self: TContractState); // maybe is not neeeded if I use a constructor
    fn fund_bet(ref self: TContractState);
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

}

#[starknet::contract]
mod Bet {
    use starknet::storage::MutableVecTrait;
use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait
    };

    #[derive(Serde, Drop)]
    struct CounterMetadata {
        id: u256,
        name: ByteArray,
        counter_address: ContractAddress
    }

    
    #[storage]
    struct Storage {
        // basic
        players: Vec<ContractAddress>,
        amount_per_player: u256,
        total_amount: u256,
        number_of_winners: u256, // 1: singleWinner mode, >2: MultiWinner mode
        
        percentage_of_distribution: Vec<u256>, // percentage of how much will gain any player
        distributions: Vec<u256>, // Real value in currency. Calculated by taking the percentage_of_distribution correspondant to positions and number of winners
        percentage_of_house_hold: u256, 
        house_hold: u256, 
        fixed_house_hold: u256,

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
        amount_per_player: u256,
        percentage_of_distribution: Array<u256>,
        percentage_of_house_hold: u256,
        fixed_house_hold:u256,
        counters: Array<CounterMetadata>,
    ) {
        for percentage in percentage_of_distribution.clone() {
            assert(percentage<=0, 'some percentages are 0');
        };
        let mut sum_of_distribution_percentages = 0_u256;
        for percentage in percentage_of_distribution.clone() {
            sum_of_distribution_percentages += percentage;
        };
        assert(sum_of_distribution_percentages>100, 'sum is greater than 100');
        // -----------------

        for player in players.clone() {
            self.players.append().write(player);
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
        
        if counters.len() > 0 {
            self.has_counters.write(true);
        }
        // to do -> Syscall to deploy each one of the counters and store it's addresses

    }

    #[abi(embed_v0)]
    impl BetImpl of super::IBet<ContractState> {
        fn init_bet(ref self: ContractState) {}
        fn fund_bet(ref self: ContractState) {}
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
    }
 
    #[generate_trait]
    impl BetInternalImpl of IBetInternal {
        // IMPORTANT -> ask how to manage mode of division 
        // Solution 1: Division always "round" down. So you can take the sobrant after distribution and add to winner, house, etc
        // Note: module operator % could be usefull here 
        fn calculate_prizes_distribution(total_amount:u256, percentage_of_distribution:@Array<u256>) -> Array<u256> {
            let mut distributions = ArrayTrait::<u256>::new();
            for percentage in percentage_of_distribution.span() {
                let prize = (total_amount * *percentage)/100;
                distributions.append(prize);
            };
            distributions
        }
        fn calculate_total_amount(amount_per_player:u256, number_of_players:u256, percentage_of_house_hold:u256, fixed_house_hold:u256) -> u256 {
            let total_amount = amount_per_player * number_of_players;
            if percentage_of_house_hold==0 {
                return total_amount - fixed_house_hold;
            };
            let real_total_amount = ((percentage_of_house_hold * total_amount)/100)-fixed_house_hold;
            real_total_amount
        }
        fn calculate_house_hold(amount_per_player:u256, number_of_players:u256, percentage_of_house_hold:u256, fixed_house_hold:u256) -> u256 {
            if percentage_of_house_hold==0 {
                return 0;
            };
            let total_amount = amount_per_player * number_of_players;
            let real_total_amount = ((percentage_of_house_hold * total_amount)/100)-fixed_house_hold;
            total_amount - real_total_amount
        }
        
    }


}
