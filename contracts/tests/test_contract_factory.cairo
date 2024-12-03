use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, spy_events, EventSpyAssertionsTrait };

use zkwager::BetFactory::IBetFactoryDispatcher;
use zkwager::BetFactory::IBetFactoryDispatcherTrait;

use zkwager::BetFactory::BetFactory::{BetCreated};
use zkwager::BetFactory::BetFactory::Event;

use zkwager::Constants::TestData::{
    ACCOUNT1,
    ACCOUNT2,
    ACCOUNT3,
};



fn CALL_DATA_TO_BET_DEPLOY () -> (Array<ContractAddress>, u128, Array<u128>, u128, u128) {
    let mut players = ArrayTrait::new();
    players.append(ACCOUNT1());
    players.append(ACCOUNT2());
    players.append(ACCOUNT3());

    let amount_per_player = 2000000000000000000;
    
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);

    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;

    (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold)

}

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    
    let mut callData = ArrayTrait::<felt252>::new();
    let bet_class_hash = declare("Bet").unwrap().contract_class().class_hash;
    bet_class_hash.serialize(ref callData);
    
    let (contract_address, _) = contract.deploy(@callData).unwrap();
    contract_address
}

#[test]
fn test_deploy() {
    deploy_contract("BetFactory");
}

fn test_generate_game_id() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };

    let id1 = dispatcher.generate_game_id();
    let id2 = dispatcher.generate_game_id();
    let id3 = dispatcher.generate_game_id();

    assert!(id1==1, "id should be {}", 1);
    assert!(id2==2, "id should be {}", 2);
    assert!(id3==3, "id should be {}", 3);
}

#[test]
fn test_create_bet() {
    let mut spy = spy_events();

    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    let game_id = dispatcher.generate_game_id();

    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();

    let bet_contract_address = dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);

    spy.assert_emitted(
        @array![
            (
                contract_address,
                (
                    Event::BetCreated(
                        BetCreated {
                            bet_contract_address,
                            amount_per_player
                        }
                    )
                )
            )
        ]
    );
}

#[test]
fn test_create_multiple_bets() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    let game_id = dispatcher.generate_game_id();
    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();
    let (players2, amount_per_player2, percentage_of_distribution2, percentage_of_house_hold2, fixed_house_hold2) = CALL_DATA_TO_BET_DEPLOY();
    
    dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);
    dispatcher.create_bet(game_id, players2, amount_per_player2, percentage_of_distribution2, percentage_of_house_hold2, fixed_house_hold2);
}

#[test]
fn test_get_bets_by_wallet() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    // creating a new bet 
    let game_id = dispatcher.generate_game_id();
    let (players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold) = CALL_DATA_TO_BET_DEPLOY();
    let bet_contract_address = dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);

    // getting bets by users 
    let player1_bets = dispatcher.get_bets_by_wallet(game_id, ACCOUNT1());
    let player2_bets = dispatcher.get_bets_by_wallet(game_id, ACCOUNT2());
    let player3_bets = dispatcher.get_bets_by_wallet(game_id, ACCOUNT3());

    assert!(bet_contract_address == *player1_bets.at(0), "Player1's first bet address should be equal to the deployed bet address");
    assert!(bet_contract_address == *player2_bets.at(0), "Player2's first bet address should be equal to the deployed bet address");
    assert!(bet_contract_address == *player3_bets.at(0), "Player3's first bet address should be equal to the deployed bet address");
}

#[test]
fn test_get_game_bets() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    let game_id = dispatcher.generate_game_id();
    let (players1, amount_per_player1, percentage_of_distribution1, percentage_of_house_hold1, fixed_house_hold1) = CALL_DATA_TO_BET_DEPLOY();
    let (players2, amount_per_player2, percentage_of_distribution2, percentage_of_house_hold2, fixed_house_hold2) = CALL_DATA_TO_BET_DEPLOY();
    let (players3, amount_per_player3, percentage_of_distribution3, percentage_of_house_hold3, fixed_house_hold3) = CALL_DATA_TO_BET_DEPLOY();
    
    // creating multiple bets
    let bet_contract_address_1 = dispatcher.create_bet(game_id, players1, amount_per_player1, percentage_of_distribution1, percentage_of_house_hold1, fixed_house_hold1);
    let bet_contract_address_2 = dispatcher.create_bet(game_id, players2, amount_per_player2, percentage_of_distribution2, percentage_of_house_hold2, fixed_house_hold2);
    let bet_contract_address_3 = dispatcher.create_bet(game_id, players3, amount_per_player3, percentage_of_distribution3, percentage_of_house_hold3, fixed_house_hold3);

    
    let game_bets = dispatcher.get_game_bets(1);

    assert!(bet_contract_address_1 == *game_bets.at(0), "first game's bet address should be equal to the first deployed bet address");
    assert!(bet_contract_address_2 == *game_bets.at(1), "second game's bet address should be equal to the second deployed bet address");
    assert!(bet_contract_address_3 == *game_bets.at(2), "third game's bet address should be equal to the third deployed bet address");
}

