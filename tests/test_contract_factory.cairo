use starknet::ContractAddress;
use starknet::syscalls::call_contract_syscall;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address, spy_events, EventSpyAssertionsTrait };
// use snforge_std::start_mock_call;
// use zkwager::Bet::IBetSafeDispatcher;
// use zkwager::Bet::IBetSafeDispatcherTrait;
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

#[test]
fn test_deploy_bet() {
    let mut spy = spy_events();

    let contract_address = deploy_contract("BetFactory");
    let dispatcher = IBetFactoryDispatcher { contract_address };

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

    let bet_contract_address = dispatcher.create_bet(players, amount_per_player, percentage_of_distribution, percentage_of_house_hold, fixed_house_hold);

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
