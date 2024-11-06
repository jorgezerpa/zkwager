#[starknet::interface]
pub trait IBet<TContractState> {
    fn create_bet(ref self: TContractState);
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
    fn deploy_counter(ref self: TContractState);
    fn get_counter_address_by_id(ref self: TContractState);
    fn get_counter_address_by_name(ref self: TContractState);

}

#[starknet::contract]
mod Bet {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait
    };


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
        number_of_winners: u16, // 1: singleWinner mode, >2: MultiWinner mode
        percentage_of_distribution: Vec<u8>, // percentage of how much will gain any player
        distribution: Vec<u8>, // Real value in currency. Calculated by taking the percentage_of_distribution correspondant to positions and number of winners

        winners: Vec<
            ContractAddress
        >, // In order, first position, second position... until length match number_of_winners
        is_bet_running: bool, // false by default, set to true when all players agree the bet, if it`s true, functions like withdraw are disabled
        players_agreement: Map<
            ContractAddress, bool
        >, // each user has to be agree with the bet before run the bet,
        house_hold: u8, // percentage of total_amount that the house wins for manage the bet 
        // GAME MODES
        // finisher -> winners are set after finish game (exp: race games, platformers like mario
        // Bros...)
        // counter -> count X number of assets,when the game is done, winners with more counts win
        // (exm -> coins collection, more kills, assets-hunting games, number of games winned, etc)
        mode: ByteArray,
        // -----
        counters: Vec<CounterMetadata>, // units counted by every user (only used on counter mode)
    }

    #[abi(embed_v0)]
    impl BetImpl of super::IBet<ContractState> {
        fn create_bet(ref self: ContractState) {}
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
        fn deploy_counter(ref self: ContractState) {}
        fn get_counter_address_by_id(ref self: ContractState) {}
        fn get_counter_address_by_name(ref self: ContractState) {}
    }
}
