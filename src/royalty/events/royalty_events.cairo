

use starknet::ContractAddress;

#[event]
#[derive(Drop, starknet::Event)]
pub enum RoyaltyEvents {
    RoyaltyCreated: RoyaltyCreated,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyCreated {

    #[key]
    pub royalty_id: u256,
    pub creator: ContractAddress,
}