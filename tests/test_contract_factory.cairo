use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, spy_events, EventSpyAssertionsTrait };

use zkwager::BetFactory::IBetFactoryDispatcher;
use zkwager::BetFactory::IBetFactoryDispatcherTrait;

use zkwager::BetFactory::BetFactory::{BetCreated};
use zkwager::BetFactory::BetFactory::Event;

fn OWNER() -> ContractAddress {
    starknet::contract_address_const::<0x123>()
}
fn ADDR1() -> ContractAddress {
    starknet::contract_address_const::<0x345>()
}
fn ADDR2() -> ContractAddress {
    starknet::contract_address_const::<0x678>()
}

fn ADDR3() -> ContractAddress {
    starknet::contract_address_const::<0x910>()
}

fn ETH_ADDR() -> ContractAddress {
    starknet::contract_address_const::<0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7>()
} 

fn STRK_ADDR() -> ContractAddress {
    starknet::contract_address_const::<0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d>()
}

fn STRK_ACCOUNT1() -> ContractAddress { // this account has 20 STRK to test transaction (only if test Forks of testnet)
    starknet::contract_address_const::<0x0416575467BBE3E3D1ABC92d175c71e06C7EA1FaB37120983A08b6a2B2D12794>()
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

fn test_generate_bet_id() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };

    let id1 = dispatcher.generate_bet_id();
    let id2 = dispatcher.generate_bet_id();
    let id3 = dispatcher.generate_bet_id();

    assert!(id1==1, "id should be {}", 1);
    assert!(id2==2, "id should be {}", 2);
    assert!(id3==3, "id should be {}", 3);
}

#[test]
fn test_create_bet() {
    let mut spy = spy_events();

    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    let game_id = dispatcher.generate_bet_id();

    let mut players = ArrayTrait::new();
    players.append(ADDR1());
    players.append(ADDR2());
    players.append(ADDR3());

    let amount_per_player = 2000000000000000000;
    
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);

    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;

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
    
    let game_id = dispatcher.generate_bet_id();

    let mut players = ArrayTrait::new();
    players.append(ADDR1());
    players.append(ADDR2());
    players.append(ADDR3());

    let amount_per_player = 2000000000000000000;
    
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);

    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;

    dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);
//   -----------------

    let mut players2 = ArrayTrait::new();
    players2.append(ADDR1());
    players2.append(ADDR2());
    players2.append(ADDR3());
    
    let mut percentage_of_distribution2 = ArrayTrait::<u128>::new();
    percentage_of_distribution2.append(33);
    percentage_of_distribution2.append(33);
    percentage_of_distribution2.append(33);

    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;

    dispatcher.create_bet(game_id, players2, amount_per_player, percentage_of_distribution2, percentage_of_house_hold, fixed_house_hold);

}

#[test]
fn test_get_bets_by_wallet() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    // creating a new bet 
    let game_id = dispatcher.generate_bet_id();
    let mut players = ArrayTrait::new();
    players.append(ADDR1());
    players.append(ADDR2());
    players.append(ADDR3());
    let amount_per_player = 2000000000000000000;
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;
    let bet_contract_address = dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);

    // getting bets by users 
    let player1_bets = dispatcher.get_bets_by_wallet(game_id, ADDR1());
    let player2_bets = dispatcher.get_bets_by_wallet(game_id, ADDR2());
    let player3_bets = dispatcher.get_bets_by_wallet(game_id, ADDR3());

    assert!(bet_contract_address == *player1_bets.at(0), "Player1's first bet address should be equal to the deployed bet address");
    assert!(bet_contract_address == *player2_bets.at(0), "Player2's first bet address should be equal to the deployed bet address");
    assert!(bet_contract_address == *player3_bets.at(0), "Player3's first bet address should be equal to the deployed bet address");
}

#[test]
fn test_get_game_bets() {
    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };
    
    let game_id = dispatcher.generate_bet_id();

    // creating multiple bets
    let bet_address1 = deploy_bets_for_test(dispatcher, game_id);
    let bet_address2 = deploy_bets_for_test(dispatcher, game_id);
    let bet_address3 = deploy_bets_for_test(dispatcher, game_id);
    
    let game_bets = dispatcher.get_game_bets(1);

    assert!(bet_address1 == *game_bets.at(0), "first game's bet address should be equal to the first deployed bet address");
    assert!(bet_address2 == *game_bets.at(1), "second game's bet address should be equal to the second deployed bet address");
    assert!(bet_address3 == *game_bets.at(2), "third game's bet address should be equal to the third deployed bet address");
}


// utils
// mod Utils {
    pub fn deploy_bets_for_test(dispatcher:IBetFactoryDispatcher, game_id:u128) -> ContractAddress  {
    
    let mut players = ArrayTrait::new();
    players.append(ADDR1());
    players.append(ADDR2());
    players.append(ADDR3());

    let amount_per_player = 2000000000000000000;

    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    
    let percentage_of_house_hold = 2;
    let fixed_house_hold = 10000000000000000;
    
    // creating multiple bets
    let bet_address = dispatcher.create_bet(game_id, players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);
    bet_address
    } 
// }