use crate::base::types::{Sample};

#[starknet::interface]
pub trait IAudioVerse<TContractState> {
    fn add_sample(
        ref self: TContractState,
        body: felt252,
    );
    fn get_sample(self: @TContractState, id: u256) -> Sample;
    fn get_sample_count(self: @TContractState) -> u256;

}
