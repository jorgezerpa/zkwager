#[starknet::interface]
pub trait IGameRegister<TContractState> {
    fn register_game(ref self: TContractState, game_name:felt252) -> starknet::ContractAddress;
    fn get_games_by_owner(ref self: TContractState) -> Array<starknet::ContractAddress>;
}

#[starknet::contract]
pub mod GameRegister {

    use starknet::storage::MutableVecTrait;
    use starknet::storage::StoragePathEntry;
    use starknet::{get_caller_address, ContractAddress, syscalls, SyscallResultTrait };
    use starknet::storage::{ Map, Vec };
    use starknet::class_hash::ClassHash;

    #[storage]
    struct Storage {
        games:Map<ContractAddress, Vec<ContractAddress>>, // deployer wallet - wallet's games
        salt_counter: u128, // increase each game deployed
        game_class_hash: ClassHash, // game contract class
        bet_class_hash: ClassHash, // bet contract class
    }

    #[constructor]
    fn constructor(ref self:ContractState, _game_class_hash:ClassHash, _bet_class_hash:ClassHash) {
        self.game_class_hash.write(_game_class_hash);
        self.bet_class_hash.write(_bet_class_hash);
        self.salt_counter.write(0);
    }

    #[abi(embed_v0)]
    impl GameRegisterImpl of super::IGameRegister<ContractState> {
        fn register_game(
            ref self: ContractState, 
            game_name:felt252,
        ) -> ContractAddress {
            let game_class_hash = self.game_class_hash.read();
            
            let mut call_data = ArrayTrait::<felt252>::new();
            let game_owner = get_caller_address();
            let bet_class_hash = self.bet_class_hash.read();
            let salt = self.salt_counter.read();

            bet_class_hash.serialize(ref call_data);
            call_data.append(game_name);

            let (game_contract_address, _) = syscalls::deploy_syscall(game_class_hash, salt.try_into().unwrap(), call_data.span(), false).unwrap_syscall();
            
            self.salt_counter.write(salt+1);
            self.games.entry(game_owner).append().write(game_contract_address);
            
            game_contract_address
        }

        fn get_games_by_owner(ref self: ContractState) -> Array<ContractAddress> {
            let mut games:Array<ContractAddress> = array![];
            let owner = get_caller_address();
            let games_vec = self.games.entry(owner);

            for index in 0..games_vec.len() {
                games.append(games_vec.at(index).read());
            };

            games
        }

    }
}
