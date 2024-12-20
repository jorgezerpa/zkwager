// use starknet::ContractAddress;

// use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address };
// // use snforge_std::start_mock_call;
// // use zkwager::Bet::IBetSafeDispatcher;
// // use zkwager::Bet::IBetSafeDispatcherTrait;
// use zkwager::Bet::IBetDispatcher;
// use zkwager::Bet::IBetDispatcherTrait;

// use openzeppelin_token::erc20::interface::{ IERC20Dispatcher, IERC20DispatcherTrait };

// use zkwager::Constants::TestData::{
//     ACCOUNT1,
//     ACCOUNT2,
//     ACCOUNT3,
//     STRK_ACCOUNT1,
//     STRK_ADDR,
// };

// fn deploy_contract(name: ByteArray) -> ContractAddress {
//     let contract = declare(name).unwrap().contract_class();

//     let mut players = ArrayTrait::new();
//     players.append(ACCOUNT1());
//     players.append(ACCOUNT2());
//     players.append(ACCOUNT3());
    
//     let mut percentage_of_distribution = ArrayTrait::<u128>::new();
//     percentage_of_distribution.append(33);
//     percentage_of_distribution.append(33);
//     percentage_of_distribution.append(33);

//     let mut callData = ArrayTrait::<felt252>::new();
//     players.serialize(ref callData);
//     callData.append(2000000000000000000); // 2 starks
//     percentage_of_distribution.serialize(ref callData);
//     callData.append(5);
//     callData.append(0);
    
//     let (contract_address, _) = contract.deploy(@callData).unwrap();
//     contract_address
// }

// #[test]
// fn test_deploy() {
//     let contract_address = deploy_contract("Bet");
//     let dispatcher = IBetDispatcher { contract_address };
//     let contract_metadata = dispatcher.get_bet_metadata();

//     // assert_eq!(3, contract_metadata.players.len(), "total players should be 3");
//     // assert_eq!(@ACCOUNT1(), contract_metadata.players.at(0), "first address should be equal to {:?}", ACCOUNT1());
//     // assert_eq!(@ACCOUNT2(), contract_metadata.players.at(1), "second address should be equal to {:?}", ACCOUNT2());
//     // assert_eq!(@ACCOUNT3(), contract_metadata.players.at(2), "third address should be equal to {:?}", ACCOUNT3());
//     // assert_eq!(contract_metadata.total_amount, 57, "total amount after house holds should be 57");
//     // assert_eq!(contract_metadata.number_of_winners, 3, "number of winners should be equal to 3");
//     // assert_eq!(contract_metadata.distributions.len(), 3, "distributions should be equal to 3");
//     // assert_eq!(*contract_metadata.distributions.at(0), 18, "Prize for position 1 should be 18");
//     // assert_eq!(*contract_metadata.distributions.at(1), 18, "Prize for position 2 should be 18");
//     // assert_eq!(*contract_metadata.distributions.at(1), 18, "Prize for position 3 should be 18");
//     // assert_eq!(contract_metadata.percentage_of_house_hold, 5, "house hold percentage should be 5");
//     // assert_eq!(contract_metadata.house_hold, 3, "value of house hold should be 3");
//     // assert_eq!(contract_metadata.fixed_house_hold, 0, "fixed house hold should be 0" );
//     // assert!(!contract_metadata.is_bet_running, "contract should not be running on deploy");
// }

// #[test]
// fn test_get_players() {
//     let contract_address = deploy_contract("Bet");
//     let dispatcher = IBetDispatcher { contract_address };
//     let players = dispatcher.get_players();

//     assert_eq!(3, players.len(), "total players should be 3");
//     assert_eq!(@ACCOUNT1(), players.at(0), "first address should be equal to {:?}", ACCOUNT1());
//     assert_eq!(@ACCOUNT2(), players.at(1), "second address should be equal to {:?}", ACCOUNT2());
//     assert_eq!(@ACCOUNT3(), players.at(2), "third address should be equal to {:?}", ACCOUNT3());
// }

// // #[test]
// // #[fork("testnet")]
// // fn test_transfer_bet() {
// //     let contract_address = deploy_contract("Bet");
// //     let strk_dispatcher = IERC20Dispatcher { contract_address: STRK_ADDR() };
    
// //     let sender = STRK_ACCOUNT1();
// //     let current_sender_balance = strk_dispatcher.balance_of(sender);
// //     let current_contract_balance = strk_dispatcher.balance_of(contract_address);
// //     let amount_to_send: u256 = 2000000000000000000; // 1 STRK (assuming 18 decimals)

// //     start_cheat_caller_address(strk_dispatcher.contract_address, sender);
// //     strk_dispatcher.transfer(contract_address, amount_to_send);
// //     let balance_sender = strk_dispatcher.balance_of(sender);
// //     let balance_bet = strk_dispatcher.balance_of(contract_address);
// //     stop_cheat_caller_address(contract_address);
    
// //     assert_eq!(current_sender_balance-amount_to_send, balance_sender, "Should transfer from sender account");
// //     assert_eq!(current_contract_balance+amount_to_send, balance_bet, "Should receive STRK from sender account");
// // }

// // Ejecutar logica al recibir una transaction 



// #[test]
// #[fork("testnet")]
// fn test_transfer_bet() {
//     let contract_address = deploy_contract("Bet");
//     let dispatcher = IBetDispatcher { contract_address };
//     let strk_dispatcher = IERC20Dispatcher { contract_address: STRK_ADDR() };

//     let sender = STRK_ACCOUNT1();
//     let amount_to_approve = 20000000000000000000; // 20 STRK

//     start_cheat_caller_address(strk_dispatcher.contract_address, sender);
//     strk_dispatcher.approve(contract_address, amount_to_approve);
//     stop_cheat_caller_address(strk_dispatcher.contract_address);
//     // start_cheat_caller_address(strk_dispatcher.contract_address, contract_address);
//     dispatcher.fund_bet(sender);   
//     // strk_dispatcher.transfer_from(sender, contract_address, 2000000000000000000);
// }


// #[test]
// #[fork("testnet")]
// fn test_get_bet_balance() {
//     let contract_address = deploy_contract("Bet");
//     let dispatcher = IBetDispatcher { contract_address };
//     let strk_dispatcher = IERC20Dispatcher { contract_address: STRK_ADDR() };
    
//     let sender = STRK_ACCOUNT1();
//     // let current_sender_balance = strk_dispatcher.balance_of(sender);
//     // let current_contract_balance = strk_dispatcher.balance_of(contract_address);
//     let amount_to_send: u256 = 2000000000000000000; // 1 STRK (assuming 18 decimals)

//     start_cheat_caller_address(strk_dispatcher.contract_address, sender);
//     strk_dispatcher.transfer(contract_address, amount_to_send);
//     stop_cheat_caller_address(contract_address);

//     let bet_balance = dispatcher.get_bet_balance();
    
//     assert_eq!(amount_to_send, bet_balance, "Bet balance should be the same as transfered amount");
// }
