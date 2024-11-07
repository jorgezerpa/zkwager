use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use bet3_contract::Bet::IBetSafeDispatcher;
use bet3_contract::Bet::IBetSafeDispatcherTrait;
use bet3_contract::Bet::IBetDispatcher;
use bet3_contract::Bet::IBetDispatcherTrait;

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

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();

    let mut players = ArrayTrait::new();
    players.append(ADDR1());
    players.append(ADDR2());
    players.append(ADDR3());
    
    let mut percentage_of_distribution = ArrayTrait::<u128>::new();
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);
    percentage_of_distribution.append(33);

    let mut callData = ArrayTrait::<felt252>::new();
    players.serialize(ref callData);
    callData.append(20);
    percentage_of_distribution.serialize(ref callData);
    callData.append(5);
    callData.append(0);
    
    let (contract_address, _) = contract.deploy(@callData).unwrap();
    contract_address
}

#[test]
fn test_deploy() {
    let contract_address = deploy_contract("Bet");
    let dispatcher = IBetDispatcher { contract_address };
    let players = dispatcher.get_players();
    let amount_per_player = dispatcher.get_amount_per_player();
    let contract_metadata = dispatcher.get_bet_metadata();

    assert_eq!(3, contract_metadata.players.len(), "total players should be 3");
    assert_eq!(@ADDR1(), contract_metadata.players.at(0), "first address should be equal to {:?}", ADDR1());
    assert_eq!(@ADDR2(), contract_metadata.players.at(1), "second address should be equal to {:?}", ADDR2());
    assert_eq!(@ADDR3(), contract_metadata.players.at(2), "third address should be equal to {:?}", ADDR3());
    assert_eq!(contract_metadata.total_amount, 57, "total amount after house holds should be 57");
    assert_eq!(contract_metadata.number_of_winners, 3, "number of winners should be equal to 3");
    assert_eq!(contract_metadata.distributions.len(), 3, "distributions should be equal to 3");
    assert_eq!(*contract_metadata.distributions.at(0), 18, "Prize for position 1 should be 18");
    assert_eq!(*contract_metadata.distributions.at(1), 18, "Prize for position 2 should be 18");
    assert_eq!(*contract_metadata.distributions.at(1), 18, "Prize for position 3 should be 18");
    assert_eq!(contract_metadata.percentage_of_house_hold, 5, "house hold percentage should be 5");
    assert_eq!(contract_metadata.house_hold, 3, "value of house hold should be 3");
    assert_eq!(contract_metadata.fixed_house_hold, 0, "fixed house hold should be 0" );
    assert!(!contract_metadata.is_bet_running, "contract should not be running on deploy");
}
