use starknet::ContractAddress;

#[starknet::interface]
pub trait IRoyalty<T> {
    fn create_royalty(ref self: T, owner: ContractAddress, payment_token: ContractAddress) -> u256;
    fn add_collaborator(ref self: T, owner: ContractAddress, royalty_id: u256, collaborator: ContractAddress, percentage: u8);
    fn add_collaborators(
            ref self: T,
            owner: ContractAddress,
            royalty_id: u256,
            collaborators: Array<ContractAddress>,
            collab_percentages: Array<u8>
        );
    fn change_royalty_owner(ref self: T, owner: ContractAddress, royalty_id: u256, new_owner: ContractAddress);
    fn accept_royalty_ownership(ref self: T, new_owner: ContractAddress, royalty_id: u256);
    fn get_balance(self: @T, user: ContractAddress) -> u256;
    fn distribute_funds(ref self: T, owner: ContractAddress, royalty_id: u256);
}