use starknet::{
    // get_caller_address, get_contract_address, get_block_timestamp, 
    ContractAddress, 
};

#[starknet::interface]
pub trait IBetFactory<TContractState> {
    fn generate_bet_id(ref self: TContractState) -> u128; // should be a hash with player data or something like that. By now, is just an incremental count
    fn create_bet(ref self: TContractState, game_id:u128, players: Array<ContractAddress>, amount_per_player: u128, percentage_of_distribution: Array<u128>, percentage_of_house_hold: u128, fixed_house_hold:u128) -> ContractAddress; 
    // fn get_bets(self: @TContractState, bet_address:ContractAddress) -> Array<ContractAddress>;
}

#[starknet::contract]
pub mod BetFactory {

    use starknet::storage::VecTrait;
use starknet::storage::MutableVecTrait;
use starknet::storage::StoragePathEntry;
use starknet::{
        // get_caller_address, get_contract_address, get_block_timestamp, 
        ContractAddress, 
        syscalls, SyscallResultTrait,
    };
    use starknet::storage::{
        Map,
        Vec
    };
    use starknet::class_hash::ClassHash;

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        BetCreated: BetCreated,
    }

    #[derive(Drop, starknet::Event)]
    pub struct BetCreated {
        #[key]
        pub bet_contract_address:ContractAddress,
        pub amount_per_player:u128
    }

    #[storage]
    struct Storage {
        game_ids: Vec<u128>,
        bet_class_hash: ClassHash,
        game_bets: Map<u128, Vec<ContractAddress>>,
        game_user_bets: Map<u128, Map<ContractAddress, Vec<ContractAddress>>>,
    }

    #[constructor]
    fn constructor(ref self:ContractState, bet_clash_hash:ClassHash) {
        self.bet_class_hash.write(bet_clash_hash);
        self.game_ids.append().write(1);
    }

    #[abi(embed_v0)]
    impl BetFactoryImpl of super::IBetFactory<ContractState> {

        fn generate_bet_id(ref self: ContractState) -> u128 {
            let last_index = self.game_ids.len() - 1;
            let last_id = self.game_ids.at(last_index).read();
            self.game_ids.append().write(last_id + 1_128);
            last_id
        }

        fn create_bet(
            ref self: ContractState, 
            game_id:u128,
            players: Array<ContractAddress>,
            amount_per_player: u128,
            percentage_of_distribution: Array<u128>,
            percentage_of_house_hold: u128,
            fixed_house_hold:u128,
            // number_of_counters: Array<CounterMetadata>,
        ) -> ContractAddress {
            // deploy contract
            let mut call_data = ArrayTrait::<felt252>::new();
            players.serialize(ref call_data);
            call_data.append(amount_per_player.try_into().unwrap());
            percentage_of_distribution.serialize(ref call_data);
            call_data.append(percentage_of_house_hold.try_into().unwrap());
            call_data.append(fixed_house_hold.try_into().unwrap());
            let bet_class_hash = self.bet_class_hash.read();
            let (bet_contract_address, _) = syscalls::deploy_syscall(bet_class_hash, 0, call_data.span(), true).unwrap_syscall();



            // save in storage
            for player in players.clone() {
                self.game_user_bets.entry(game_id).entry(player).append().write(bet_contract_address);
            };

            self.game_bets.entry(game_id).append().write(bet_contract_address);

            // emit event 
            self
                .emit(
                    BetCreated {
                        bet_contract_address,
                        amount_per_player
                    }
                );

            // return 
            bet_contract_address
        }

        // fn get_bets(self: @ContractState, bet_address:ContractAddress) -> Array<ContractAddress> {
        //     let bets_vec = self.bets.entry(bet_address);
        //     let mut bets_array = ArrayTrait::<ContractAddress>::new();

        //     for i in 0..bets_vec.len() {
        //         bets_array.append(bets_vec.at(i).read());
        //     };

        //     bets_array
        // }
    }
 
    // #[generate_trait]
    // impl BetInternalImpl of IBetInternal {}

}
