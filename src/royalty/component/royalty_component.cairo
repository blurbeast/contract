



#[starknet::component]
pub mod Royalty {

    #[event]
    use audioverse::royalty::events::royalty_events::Event;
    use audioverse::royalty::events::royalty_events::{
        RoyaltyCreated, RoyaltyUpdated, PercentageUpdated, WithdrawShare
    };
    // use audioverse::royalty::entities::royalty_entities::Royalty;
    use starknet::storage::{ Map, StoragePathEntry, Vec, VecTrait };
    use starknet::ContractAddress;


    #[storage]
    pub struct Storage {
        royalty_id_counter: u256,
        // user_royalty_balance: Map<(u256, ContractAddress), u256>, // (royalty_id, user) to balance
        user_royalty_percentage: Map<(u256, ContractAddress), u256>, // (royalty_id, user) to percentage
        royalty_to_collaborator_count: Map<u256, u256>, // royalty_id to collaborator count , number of collaborators in a royalty
        royalty_to_collaborators: Map<u256, Vec<ContractAddress>>, // royalty_id to collaborators
        royalties: Map<u256, (ContractAddress, u256, ContractAddress)>, // id to Royalty (owner, received_funds, payment_token)
        user_royalties: Map<ContractAddress, u256>, // user total royalties
    }


    #[generate_trait]
    impl RoyaltyImpl<TContractState, +Drop<TContractState>, +HasComponent<TContractState>> of IRoyalty<TContractState> {
        
    }
}