// use starknet::ContractAddress;

// use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address };


// use zkwager::GameRegister::IGameRegisterDispatcher;
// use zkwager::GameRegister::IGameRegisterDispatcherTrait;

// // use zkwager::BetFactory::BetFactory::{BetCreated};
// // use zkwager::BetFactory::BetFactory::Event;

// use zkwager::Constants::TestData::{
//     ACCOUNT1,
//     ACCOUNT2,
//     ACCOUNT3,
// };


// fn deploy_game_register() -> (IGameRegisterDispatcher,ContractAddress) {
//     let contract = declare("GameRegister").unwrap().contract_class();
    
//     let mut callData = ArrayTrait::<felt252>::new();
//     let game_class_hash = declare("Game").unwrap().contract_class().class_hash;
//     let bet_class_hash = declare("Bet").unwrap().contract_class().class_hash;
//     game_class_hash.serialize(ref callData);
//     bet_class_hash.serialize(ref callData);
    
//     let (contract_address, _) = contract.deploy(@callData).unwrap();
//     let game_register_dispatcher = IGameRegisterDispatcher { contract_address };
//     (game_register_dispatcher, contract_address)
// }

// #[test]
// fn test_deploy() {
//     deploy_game_register();
// }

// #[test]
// fn test_register_game() {
//     let (game_register_dispatcher, _contract_address) = deploy_game_register();
//     let game_name = 'my super new game';
//     game_register_dispatcher.register_game(game_name);
//     let owner_games = game_register_dispatcher.get_games_by_owner();
//     assert_eq!(owner_games.len(), 1, "A game should be registered for the caller address.");
// }

// #[test]
// fn test_register_multiple_games_salt() {
//     let (game_register_dispatcher, _contract_address) = deploy_game_register();
//     let game_name = 'my super new game';
//     game_register_dispatcher.register_game(game_name);
//     game_register_dispatcher.register_game(game_name);
//     game_register_dispatcher.register_game(game_name);
//     let owner_games = game_register_dispatcher.get_games_by_owner();
//     assert_eq!(owner_games.len(), 3, "3 games should be registered for the caller address.");
// }

// #[test]
// fn test_register_multiple_games_from_different_addresses() {
//     let (game_register_dispatcher, _contract_address) = deploy_game_register();
//     let game_name = 'my super new game';

//     let owner1 = ACCOUNT1();
//     let owner2 = ACCOUNT2();
//     let owner3 = ACCOUNT3();

//     // creating games from different addresses
//     start_cheat_caller_address(_contract_address, owner1);
//     game_register_dispatcher.register_game(game_name);
//     let owner_games_1 = game_register_dispatcher.get_games_by_owner();
//     stop_cheat_caller_address(_contract_address);
    
//     start_cheat_caller_address(_contract_address, owner2);
//     game_register_dispatcher.register_game(game_name);
//     let owner_games_2 = game_register_dispatcher.get_games_by_owner();
//     stop_cheat_caller_address(_contract_address);
    
//     start_cheat_caller_address(_contract_address, owner3);
//     game_register_dispatcher.register_game(game_name);
//     let owner_games_3 = game_register_dispatcher.get_games_by_owner();
//     stop_cheat_caller_address(_contract_address);

//     // asserting 
//     assert_eq!(owner_games_1.len(), 1, "1 game should be registered for first called address.");
//     assert_eq!(owner_games_2.len(), 1, "2 game should be registered for second called address.");
//     assert_eq!(owner_games_3.len(), 1, "3 game should be registered for third called address.");
// }

