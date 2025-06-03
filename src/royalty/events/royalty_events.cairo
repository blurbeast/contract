

use starknet::ContractAddress;

// #[event]
#[derive(Drop, starknet::Event)]
pub enum Event {
    RoyaltyCreated: RoyaltyCreated,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyCreated {
    #[key]
    pub royalty_id: u256,
    pub creator: ContractAddress,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyUpdated {
    #[key]
    pub royalty_id: u256,
    pub new_creator: ContractAddress,
    pub previous_creator: ContractAddress,
}

#[derive(Drop, starknet::Event)]
pub struct PercentageUpdated {
    #[key]
    pub royalty_id: u256,
    collaborator: ContractAddress,
    percentage: u256,
}

#[derive(Drop, starknet::Event)]
pub struct WithdrawShare {
    #[key]
    pub royalty_id: u256,
    user: ContractAddress,
    amount: u256,
}