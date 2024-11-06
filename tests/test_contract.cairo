use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use bet3_contract::Bet::IBetSafeDispatcher;
use bet3_contract::Bet::IBetSafeDispatcherTrait;
use bet3_contract::Bet::IBetDispatcher;
use bet3_contract::Bet::IBetDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_deploy() {
    let contract_address = deploy_contract("Bet");
    let dispatcher = IBetDispatcher { contract_address };

    // deploy should:
    // 1. set values from constructor
    // 2. deploy counters
}

// #[test]
// fn test_increase_balance() {
//     let contract_address = deploy_contract("Bet");

//     let dispatcher = IBetDispatcher { contract_address };
//     let value = dispatcher.test();
//     println!("value {}", value);
//     assert_eq!(value,7);
//     // let balance_before = dispatcher.get_balance();
//     // assert(balance_before == 0, 'Invalid balance');

//     // dispatcher.increase_balance(42);

//     // let balance_after = dispatcher.get_balance();
//     // assert(balance_after == 42, 'Invalid balance');
// }
