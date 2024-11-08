use starknet::ContractAddress;
use starknet::syscalls::call_contract_syscall;

use snforge_std::{start_mock_call, stop_mock_call, mock_call, declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address, cheat_caller_address, CheatSpan };
// use snforge_std::start_mock_call;
// use bet3_contract::Bet::IBetSafeDispatcher;
// use bet3_contract::Bet::IBetSafeDispatcherTrait;
use bet3_contract::Bet::IBetDispatcher;
use bet3_contract::Bet::IBetDispatcherTrait;

use openzeppelin_token::erc20::{ERC20Component, ERC20HooksEmptyImpl };
use openzeppelin_token::erc20::interface::{ IERC20Dispatcher, IERC20DispatcherTrait };

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

#[test]
fn test_get_players() {
    let contract_address = deploy_contract("Bet");
    let dispatcher = IBetDispatcher { contract_address };
    let players = dispatcher.get_players();

    assert_eq!(3, players.len(), "total players should be 3");
    assert_eq!(@ADDR1(), players.at(0), "first address should be equal to {:?}", ADDR1());
    assert_eq!(@ADDR2(), players.at(1), "second address should be equal to {:?}", ADDR2());
    assert_eq!(@ADDR3(), players.at(2), "third address should be equal to {:?}", ADDR3());
}

#[test]
#[fork("testnet")]
fn test_transfer_bet() {
    let contract_address = deploy_contract("Bet");
    let strk_dispatcher = IERC20Dispatcher { contract_address: STRK_ADDR() };
    
    let sender = STRK_ACCOUNT1();
    let current_sender_balance = strk_dispatcher.balance_of(sender);
    let current_contract_balance = strk_dispatcher.balance_of(contract_address);
    let amount_to_send: u256 = 2000000000000000000; // 1 STRK (assuming 18 decimals)

    start_cheat_caller_address(strk_dispatcher.contract_address, sender);
    strk_dispatcher.transfer(contract_address, amount_to_send);
    let balance_sender = strk_dispatcher.balance_of(sender);
    let balance_bet = strk_dispatcher.balance_of(contract_address);
    stop_cheat_caller_address(contract_address);
    
    assert_eq!(current_sender_balance-amount_to_send, balance_sender, "Should transfer from sender account");
    assert_eq!(current_contract_balance+amount_to_send, balance_bet, "Should receive STRK from sender account");
}

// #[test]
// #[fork("Mainnet")]
// fn test_transfer_bet() {
//     let contract_address = deploy_contract("Bet");
//     let dispatcher = IBetDispatcher { contract_address };
    
//     let sender: ContractAddress = starknet::contract_address_const::<0x0416575467BBE3E3D1ABC92d175c71e06C7EA1FaB37120983A08b6a2B2D12794>();
//     let amount: u256 = 1000000000000000000; // 1 STRK (assuming 18 decimals)
    
//     // Mock the STRK token contract
//     let strk_dispatcher = IERC20Dispatcher { contract_address: STRK_ADDR() };
    
//     // Start mocking the balance_of function of the STRK contract
//     start_mock(strk_dispatcher.contract_address, 'balance_of');
    
//     // Mock the balance of the sender to be 10 STRK
//     mock_call(strk_dispatcher.contract_address, 'balance_of', (sender,)).returns(10000000000000000000);
    
//     // Start mocking the transfer function
//     start_mock(strk_dispatcher.contract_address, 'transfer');
    
//     // Mock a successful transfer
//     mock_call(strk_dispatcher.contract_address, 'transfer', (contract_address, amount)).returns(true);
    
//     // Perform the transfer
//     start_cheat_caller_address(contract_address, sender);
//     strk_dispatcher.transfer(contract_address, amount);
    
//     // Check the balance (this will return the mocked value)
//     let value = strk_dispatcher.balance_of(sender);
//     println!("sender balance {}", value);
    
//     stop_cheat_caller_address(contract_address);
    
//     // Stop mocking
//     stop_mock(strk_dispatcher.contract_address, 'balance_of');
//     stop_mock(strk_dispatcher.contract_address, 'transfer');
// }
