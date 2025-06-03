

// use starknet::ContractAddress;
// use starknet::storage::{ Vec, VecTrait, };



// #[derive(Drop, Serde, starknet::Store)]
// pub struct Royalty {
//     pub royalty_id: u256,
//     pub creator: ContractAddress,
//     pub collaborators: Vec<ContractAddress>, // collaborator address to percentage
//     pub percentages: Vec<u256>, // percentage for each collaborator
//     pub total_percentage: u256, // total percentage of all collaborators
//     pub total_royalties: u256, // total royalties collected
//     pub payment_token: ContractAddress, // address of the token to be used 
// }   