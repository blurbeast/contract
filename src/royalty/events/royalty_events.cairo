

use starknet::ContractAddress;

// #[event]
#[derive(Drop, starknet::Event)]
pub enum Event {
    RoyaltyCreated: RoyaltyCreated,
    RoyaltyOwnershipUpdated: RoyaltyOwnershipUpdated,
    RoyaltyShareDistributed: RoyaltyShareDistributed,
    WithdrawShare: WithdrawShare,
    CollaboratorAdded: CollaboratorAdded,
    RoyaltyOwnershipChangeRequested: RoyaltyOwnershipChangeRequested,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyCreated {
    #[key]
    pub royalty_id: u256,
    pub creator: ContractAddress,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyOwnershipUpdated {
    #[key]
    pub royalty_id: u256,
    pub new_creator: ContractAddress,
    pub previous_creator: ContractAddress,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyShareDistributed {
    #[key]
    pub royalty_id: u256,
    pub collaborator: ContractAddress,
    pub percentage: u8,
}

#[derive(Drop, starknet::Event)]
pub struct WithdrawShare {
    #[key]
    pub royalty_id: u256,
    pub user: ContractAddress,
    pub amount: u256,
}

#[derive(Drop, starknet::Event)]
pub struct CollaboratorAdded {
    #[key]
    pub royalty_id: u256,
    #[key]
    pub collaborator_index: u256, // index of the collaborator in the royalty
    pub collaborator: ContractAddress,
    pub percentage: u8,
    pub number_of_collaborators: u256,
}

#[derive(Drop, starknet::Event)]
pub struct RoyaltyOwnershipChangeRequested {
    #[key]
    pub royalty_id: u256,
    pub new_owner: ContractAddress,
}