/// Main contract implementation
#[starknet::contract]
mod AudioVerse {
    use audioverse::interfaces::IAudioVerse::IAudioVerse;
    use core::num::traits::Zero;
    use core::traits::Into;
    use starknet::storage::Map;
    use starknet::{
        ClassHash, ContractAddress, get_block_timestamp, get_caller_address, get_contract_address,
    };
    use crate::base::errors::Errors::{SAMPLE_BODY_EMPTY, SAMPLE_NOT_FOUND};
    use crate::base::types::Sample;
    use crate::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};

    use audioverse::royalty::component::royalty_component::Royalty;
    // use audioverse::royalty::component::royalty_component::RoyaltyImpl;

    component!(path: Royalty, storage: royalty, event: RoyaltyEvent);


    #[storage]
    struct Storage {
        samples: Map<u256, Sample>,
        sample_count: u256,
        #[substorage(v0)]
        royalty: Royalty::Storage,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        SampleEvent: SampleEvent,
        #[flat]
        RoyaltyEvent: Royalty::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct SampleEvent {
        id: u256,
        body: felt252,
        add_time: u64,
        creator: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {}

    #[abi(embed_v0)]
    impl AudioVerseImpl of IAudioVerse<ContractState> {
        fn add_sample(ref self: ContractState, body: felt252) {
            assert(body == '', SAMPLE_BODY_EMPTY);
            let caller = get_caller_address();
            let timestamp: u64 = get_block_timestamp();
            let current_sample_count = self.sample_count.read();
            let id: u256 = current_sample_count + 1;
            let sample = Sample { id, body, creator: caller, add_time: timestamp };
            self.samples.write(id, sample);
            self.sample_count.write(current_sample_count);
            self
                .emit(
                    Event::SampleEvent(
                        SampleEvent { creator: caller, id, body, add_time: timestamp },
                    ),
                );
        }
        
        fn get_sample(self: @ContractState, id: u256) -> Sample {
            self.samples.read(id)
        }

        fn get_sample_count(self: @ContractState) -> u256 {
            self.sample_count.read()
        }
    }
}
