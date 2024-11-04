#[starknet::interface]
pub trait IBet<TContractState> {
    fn test(ref self: TContractState) -> u8;
    fn create_bet(ref self: TContractState);
    fn cancel_bet(ref self: TContractState);
    fn set_winner(ref self: TContractState);
    fn set_winners(ref self: TContractState);
    fn withdraw_winner(ref self: TContractState);
    fn set_winners_in_counter_mode(ref self: TContractState);
    // fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod Bet {
    use starknet::{ContractAddress, get_caller_address};
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess, Vec, VecTrait
    };


    #[storage]
    struct Storage {
        // basic
        players: Vec<ContractAddress>,
        amount_per_player: u256,
        total_amount: u256,
        number_of_winners: u16, // 1: singleWinner mode, >2: MultiWinner mode
        distribution_of_prizes: Vec<u8>, // percentage of how much will gain any player
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
        counter: Map<ContractAddress, u256>, // units counted by every user (only used on counter mode)
    }

    #[abi(embed_v0)]
    impl BetImpl of super::IBet<ContractState> {
        // fn create_bet(ref self: ContractState) {}
        fn test(ref self: ContractState) -> u8 {
            7
        }
        fn create_bet(ref self: ContractState) {}
        fn cancel_bet(ref self: ContractState) {}
        fn set_winner(ref self: ContractState) {}
        fn set_winners(ref self: ContractState) {}
        fn withdraw_winner(ref self: ContractState) {}
        fn set_winners_in_counter_mode(ref self: ContractState) {}
    }
}
