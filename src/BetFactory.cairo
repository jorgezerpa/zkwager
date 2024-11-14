use starknet::{
    // get_caller_address, get_contract_address, get_block_timestamp, 
    ContractAddress, 
};

#[starknet::interface]
pub trait IBetFactory<TContractState> {
    fn create_bet(ref self: TContractState, players: Array<ContractAddress>, amount_per_player: u128, percentage_of_distribution: Array<u128>, percentage_of_house_hold: u128, fixed_house_hold:u128) -> ContractAddress; 
    fn get_bets(self: @TContractState, bet_address:ContractAddress) -> Array<ContractAddress>;
}

#[starknet::contract]
mod BetFactory {

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

    #[storage]
    struct Storage {
       bet_class_hash: ClassHash,
       bets: Map<ContractAddress, Vec<ContractAddress>>, // bet address - players
    }

    #[constructor]
    fn constructor(ref self:ContractState, bet_clash_hash:ClassHash) {
        self.bet_class_hash.write(bet_clash_hash);
    }

    #[abi(embed_v0)]
    impl BetFactoryImpl of super::IBetFactory<ContractState> {
        fn create_bet(
            ref self: ContractState, 
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
            for player in players {
                self.bets.entry(bet_contract_address).append().write(player);
            };

            // return 
            bet_contract_address
        }

        fn get_bets(self: @ContractState, bet_address:ContractAddress) -> Array<ContractAddress> {
            let bets_vec = self.bets.entry(bet_address);
            let mut bets_array = ArrayTrait::<ContractAddress>::new();

            for i in 0..bets_vec.len() {
                bets_array.append(bets_vec.at(i).read());
            };

            bets_array
        }
    }
 
    // #[generate_trait]
    // impl BetInternalImpl of IBetInternal {}

}
