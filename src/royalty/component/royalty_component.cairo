



#[starknet::component]
pub mod Royalty {

    #[event]
    use audioverse::royalty::events::royalty_events::Event;
    use audioverse::royalty::events::royalty_events::{
        RoyaltyCreated, RoyaltyUpdated, PercentageUpdated, WithdrawShare
    };


    #[storage]
    pub struct Storage {
        
    }
}