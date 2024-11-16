
    use starknet::ContractAddress;

    // accounts
    pub fn OWNER() -> ContractAddress {
        starknet::contract_address_const::<0x123>()
    }
    pub fn ACCOUNT1() -> ContractAddress {
        starknet::contract_address_const::<0x345>()
    }
    pub fn ACCOUNT2() -> ContractAddress {
        starknet::contract_address_const::<0x678>()
    }
    
    pub fn ACCOUNT3() -> ContractAddress {
        starknet::contract_address_const::<0x910>()
    }
    
    // accounts with STRK 
    pub fn STRK_ACCOUNT1() -> ContractAddress { // this account has 20 STRK to test transaction (only if test Forks of testnet)
        starknet::contract_address_const::<0x0416575467BBE3E3D1ABC92d175c71e06C7EA1FaB37120983A08b6a2B2D12794>()
    } 
    
    pub fn STRK_ACCOUNT2() -> ContractAddress { // this account has 20 STRK to test transaction (only if test Forks of testnet)
        starknet::contract_address_const::<0x0092fB909857ba418627B9e40A7863F75768A0ea80D306Fb5757eEA7DdbBd4Fc>()
    } 
    
    pub fn STRK_ACCOUNT3() -> ContractAddress { // this account has 20 STRK to test transaction (only if test Forks of testnet)
        starknet::contract_address_const::<0x05f76B9ADf5D18Ca000ef6e7e9B7cBef63c72749426E91C1b206b42CEDAd7E1E>()
    }
    
    // ERC20 contract address
    pub fn ETH_ADDR() -> ContractAddress {
        starknet::contract_address_const::<0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7>()
    } 
    
    pub fn STRK_ADDR() -> ContractAddress {
        starknet::contract_address_const::<0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d>()
    }
