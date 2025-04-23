use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct Sample {
    pub id: u256,
    pub body: felt252,
    pub creator: ContractAddress,
    pub add_time: u64,
}
