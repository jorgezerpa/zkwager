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
fn test_increase_balance() {
    let contract_address = deploy_contract("Bet");

    let dispatcher = IBetDispatcher { contract_address };
    let value = dispatcher.test();
    println!("value {}", value);
    assert_eq!(value,7);
    // let balance_before = dispatcher.get_balance();
    // assert(balance_before == 0, 'Invalid balance');

    // dispatcher.increase_balance(42);

    // let balance_after = dispatcher.get_balance();
    // assert(balance_after == 42, 'Invalid balance');
}

// #[test]
// #[feature("safe_dispatcher")]
// fn test_cannot_increase_balance_with_zero_value() {
//     let contract_address = deploy_contract("Bet");

//     let safe_dispatcher = IBetSafeDispatcher { contract_address };

//     let balance_before = safe_dispatcher.get_balance().unwrap();
//     assert(balance_before == 0, 'Invalid balance');

//     match safe_dispatcher.increase_balance(0) {
//         Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
//         Result::Err(panic_data) => {
//             assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
//         }
//     };
// }
