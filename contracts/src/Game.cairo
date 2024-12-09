use starknet::{ 
    ContractAddress, 
};

#[starknet::interface]
pub trait IGame<TContractState> {
    // fn create_bet(ref self: TContractState, game_id:u128, players: Array<ContractAddress>, amount_per_player: u128, percentage_of_distribution: Array<u128>, percentage_of_house_hold: u128, fixed_house_hold:u128) -> ContractAddress; 
    // fn get_bets_by_wallet(self: @TContractState, game_id:u128, player:ContractAddress) -> Array<ContractAddress>;
    // fn get_game_bets(self: @TContractState, game_id:u128) -> Array<ContractAddress>;
}

#[starknet::contract]
pub mod Game {

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
        bet_class_hash: ClassHash, // Class hash of the contract in charge of managing bet logic
        game_name: felt252,
        game_bets: Vec<ContractAddress>, // list of all the bets of the game. TO DO -> store an struct with more data instead of only the address
        game_user_bets: Map<ContractAddress, Vec<ContractAddress>>, // mapping player's Wallet -> Bets to easy and fastest access of player's bets 
        salt_counter: u128, // salt incremental value that increase each time a bet is deployed
    }

    #[constructor]
    fn constructor(ref self:ContractState, bet_clash_hash:ClassHash, game_name:felt252) {
        self.bet_class_hash.write(bet_clash_hash);
        self.game_name.write(game_name);
    }

    #[abi(embed_v0)]
    impl GameImpl of super::IGame<ContractState> {

       
        // fn create_bet(
        //     ref self: ContractState, 
        //     game_id:u128,
        //     players: Array<ContractAddress>,
        //     amount_per_player: u128,
        //     percentage_of_distribution: Array<u128>,
        //     percentage_of_house_hold: u128,
        //     fixed_house_hold:u128,
        //     // number_of_counters: Array<CounterMetadata>,
        // ) -> ContractAddress {
        //     // deploy contract
        //     let mut call_data = ArrayTrait::<felt252>::new();
        //     players.serialize(ref call_data);
        //     call_data.append(amount_per_player.try_into().unwrap());
        //     percentage_of_distribution.serialize(ref call_data);
        //     call_data.append(percentage_of_house_hold.try_into().unwrap());
        //     call_data.append(fixed_house_hold.try_into().unwrap());
        //     let bet_class_hash = self.bet_class_hash.read();

        //     let salt = self.salt_counter.read();
        //     self.salt_counter.write(salt+1);

        //     let (bet_contract_address, _) = syscalls::deploy_syscall(bet_class_hash, salt.try_into().unwrap(), call_data.span(), false).unwrap_syscall();

        //     // save in storage
        //     for player in players.clone() {
        //         self.game_user_bets.entry(game_id).entry(player).append().write(bet_contract_address);
        //     };

        //     self.game_bets.entry(game_id).append().write(bet_contract_address);

        //     // emit event 
        //     self
        //         .emit(
        //             BetCreated {
        //                 bet_contract_address,
        //                 amount_per_player
        //             }
        //         );

        //     // return 
        //     bet_contract_address
        // }
        
        // fn get_bets_by_wallet(self: @ContractState, game_id:u128, player:ContractAddress) -> Array<ContractAddress> {
        //     // get vector of player's bet addresses
        //     let bets_vec = self.game_user_bets.entry(game_id).entry(player);
        //     // convert vector into an array and return it 
        //     let mut bets_array = ArrayTrait::<ContractAddress>::new();
        //     for i in 0..bets_vec.len() {
        //         bets_array.append(bets_vec.at(i).read());
        //     };

        //     bets_array
        // }

        // fn get_game_bets(self: @ContractState, game_id:u128) -> Array<ContractAddress> {
        //     // get vector of player's bet addresses
        //     let bets_vec = self.game_bets.entry(game_id);
        //     // convert vector into an array and return it 
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