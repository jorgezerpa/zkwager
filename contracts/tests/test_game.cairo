use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address };


use zkwager::GameRegister::IGameRegisterDispatcher;
use zkwager::GameRegister::IGameRegisterDispatcherTrait;

use zkwager::Game::IGameDispatcher;
use zkwager::Game::IGameDispatcherTrait;


use zkwager::Constants::TestData::{
    ACCOUNT1,
    ACCOUNT2,
    ACCOUNT3,
};


fn deploy_game() -> (IGameDispatcher,ContractAddress) {
    // deploy Game Register
    let contract = declare("GameRegister").unwrap().contract_class();
    let mut callData = ArrayTrait::<felt252>::new();
    let game_class_hash = declare("Game").unwrap().contract_class().class_hash;
    let bet_class_hash = declare("Bet").unwrap().contract_class().class_hash;
    game_class_hash.serialize(ref callData);
    bet_class_hash.serialize(ref callData);
    let (contract_address, _) = contract.deploy(@callData).unwrap();
    let game_register_dispatcher = IGameRegisterDispatcher { contract_address };
    
    // deploy Game using game register
    let game_name = 'my super new game';
    let game_address = game_register_dispatcher.register_game(game_name);
    let game_dispatcher = IGameDispatcher { contract_address:game_address };
    (game_dispatcher, game_address)
}

#[test]
fn test_deploy() {
    deploy_game();
}

#[test]
fn test_get_metadata() {
    let (game_dispatcher, _game_address) = deploy_game();
    let game_metadata = game_dispatcher.get_game_metadata();
    assert_eq!(game_metadata, 'my super new game', "The name should be the same as the one deployed");
}

#[test]
fn test_create_bet() {
    let (game_dispatcher, _game_address) = deploy_game();
    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();
    game_dispatcher.create_bet(players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);
}

#[test]
fn get_bets_by_wallet() {
    let (game_dispatcher, _game_address) = deploy_game();
    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();
    
    game_dispatcher.create_bet(players.clone(), amount_per_player, percentage_of_distribution.clone(), percentage_of_house_hold, fixed_house_hold);
    game_dispatcher.create_bet(players.clone(), amount_per_player, percentage_of_distribution.clone(), percentage_of_house_hold, fixed_house_hold);

    let player1 = players.at(0);
    let player2 = players.at(1);
    let player3 = players.at(2);

    let player_bets_1 = game_dispatcher.get_bets_by_wallet(*player1);
    let player_bets_2 = game_dispatcher.get_bets_by_wallet(*player2);
    let player_bets_3 = game_dispatcher.get_bets_by_wallet(*player3);

    assert_eq!(player_bets_1.len(), 2, "player 1 should have 2 bets related.");
    assert_eq!(player_bets_2.len(), 2, "player 2 should have 2 bets related.");
    assert_eq!(player_bets_3.len(), 2, "player 3 should have 2 bets related.");
}

#[test]
fn get_game_bets() {
    let (game_dispatcher, _game_address) = deploy_game();
    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();
    
    game_dispatcher.create_bet(players.clone(), amount_per_player, percentage_of_distribution.clone(), percentage_of_house_hold, fixed_house_hold);
    game_dispatcher.create_bet(players.clone(), amount_per_player, percentage_of_distribution.clone(), percentage_of_house_hold, fixed_house_hold);
    game_dispatcher.create_bet(players.clone(), amount_per_player, percentage_of_distribution.clone(), percentage_of_house_hold, fixed_house_hold);

    let game_bets = game_dispatcher.get_game_bets();

    assert_eq!(game_bets.len(), 3, "Game should have 3 bets registerd");
}


fn CALL_DATA_TO_BET_DEPLOY() -> (Array<ContractAddress>, u128, Array<u128>, u128, u128) {
    let mut players = ArrayTrait::new();
    players.append(ACCOUNT1());
    players.append(ACCOUNT2());
    players.append(ACCOUNT3());
    let amount_per_player = 2000000000000000000;
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(60);
    percentage_of_distribution.append(40);
    let percentage_of_house_hold = 1;
    // let fixed_house_hold = 1000000000000000000;
    let fixed_house_hold = 0;
    (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold)
}
