

use starknet::ContractAddress;



#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct Royalty {
    pub royalty_id: u256,
    pub creator: ContractAddress,
    pub collaborators: LegacyMap<ContractAddress, u256>, // collaborator to percentage
    pub total_percentage: u256,
    pub payment_token: ContractAddress, // address of the token to be used 
}