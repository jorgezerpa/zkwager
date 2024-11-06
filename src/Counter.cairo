#[starknet::interface]
pub trait ICounter<TContractState> {
    fn add_value(ref self: TContractState);
    fn get_values_by_user(ref self: TContractState);
    fn get_total_values(ref self: TContractState);
    fn get_(ref self: TContractState);
    fn get_counter_metadata(ref self: TContractState);
    fn get_counter_bias(ref self: TContractState);
}

#[starknet::contract]
mod Counter {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait
    };

    #[storage]
    struct Storage {
        // metadata
        id: u256,
        name: ByteArray,
        counter_address: ContractAddress,
        bias_on_final_calculation: u32, // multiplies the values on values map
        // -----
        players: Vec<ContractAddress>,
        values: Map<ContractAddress, u256>, // on constructor all values in player are initialized in zero here (it is needed? or cairo already makes that?)
    }

    #[constructor]
    fn constructor(ref self: ContractState, id: u256, name:ByteArray) {
        self.id.write(id);
        self.name.write(name);
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn add_value(ref self: ContractState) {}
        fn get_values_by_user(ref self: ContractState) {}
        fn get_total_values(ref self: ContractState) {}
        fn get_(ref self: ContractState) {}
        fn get_counter_metadata(ref self: ContractState) {}
        fn get_counter_bias(ref self: ContractState) {}
    }
}
