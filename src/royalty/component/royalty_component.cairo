



#[starknet::component]
pub mod Royalty {

    #[event]
    use audioverse::royalty::events::royalty_events::Event;
    use audioverse::royalty::events::royalty_events::{
        RoyaltyCreated, RoyaltyOwnershipUpdated, RoyaltyShareDistributed, WithdrawShare
    };
    use starknet::storage::{ StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry, };
    use starknet::{ContractAddress, };


    #[storage]
    pub struct Storage {
        royalty_id_counter: u256, // user_royalty_balance: Map<(u256, ContractAddress), u256>, // (royalty_id, user) to balance
        user_royalty_percentage: Map<(u256, ContractAddress), u8>, // (royalty_id, user) to percentage
        royalty_to_collaborator_count: Map<u256, u256>, // royalty_id to collaborator count , number of collaborators in a royalty
        royalties: Map<u256, (ContractAddress, u256, ContractAddress)>, // id to Royalty (owner, received_funds, payment_token)
        user_royalties: Map<ContractAddress, u256>, // user total funds received from royalties
        is_royalty_collaborator: Map<(u256, ContractAddress), bool>, // (royalty_id, user) to is_collaborator
        royalty_collaborator_percentage_tracker: Map<u256, u8>, // royalty_id to percentage tracker, used to track the total percentage of all collaborators
        royalty_owner_percentage_tacker: Map<u256, u8>,
    }


    #[generate_trait]
    impl RoyaltyImpl<TContractState, +Drop<TContractState>, +HasComponent<TContractState>> of IRoyalty<TContractState> {
        
        fn create_royalty(ref self: ComponentState<TContractState>, owner: ContractAddress, payment_token: ContractAddress) -> u256 {
            // assert!(owner);
            // read the current royalty id counter and increment it
            let royalty_id = self.royalty_id_counter.read() + 1 ;

            self.royalties.entry(royalty_id).write((owner, 0, payment_token));
            // set the new colaborators up
            let royalty_number_of_collab = self.royalty_to_collaborator_count.entry(royalty_id).read();

            // update the 
            self.royalty_to_collaborator_count.entry(royalty_id).write(royalty_number_of_collab + 1);
            // set the owner as a collaborator
            self.is_royalty_collaborator.entry((royalty_id, owner)).write(true);

            // set the owner percentage to 100%
            self.user_royalty_percentage.entry((royalty_id, owner)).write(100);
            // upon creation owner takes 100% of the royalties
            self.royalty_owner_percentage_tacker.entry(royalty_id).write(100);
            self.royalty_collaborator_percentage_tracker.entry(royalty_id).write(0);

            // save the new royalty counter in the storage
            self.royalty_id_counter.write(royalty_id);
            return royalty_id;
        }

        fn add_collaborator(ref self: ComponentState<TContractState>, owner: ContractAddress, royalty_id: u256, collaborator: ContractAddress, percentage: u8) {
            assert!(royalty_id > 0, "Royalty ID must be greater than 0");
            assert!(royalty_id <= self.royalty_id_counter.read(), "Royalty ID does not exist");
            assert!(collaborator != owner, "Collaborator cannot be the owner");
            assert!(percentage > 0 && percentage <= 100, "Percentage must be between 1 and 100");

            // // check if the owner is the creator of the royalty
            let (creator, _, _) = self.royalties.entry(royalty_id).read();
            assert!(creator == owner, "Only the creator can add collaborators");

            // //check if the collaborator already exists
            let result = self.is_royalty_collaborator.entry((royalty_id, collaborator)).read();
            assert!(!result, "Collaborator already exists");

            let percentage_tracker = self.royalty_collaborator_percentage_tracker.entry(royalty_id).read();
            let owner_percentage_tracker = self.royalty_owner_percentage_tacker.entry(royalty_id).read();
            assert!(percentage_tracker + percentage <= 100, "Total percentage cannot exceed 100");

            // // confirm owner percentage tracker
            // let owner_percentage_tracker = self.royalty_owner_percentage_tacker.entry((royalty_id,)).read();
            assert!((owner_percentage_tracker - percentage) > 0, "Owner percentage cannot be 0");
            assert!((owner_percentage_tracker - percentage) + (percentage_tracker + percentage) <= 100, "percentage cannot exceed 100");


            // // now update all states
            self.is_royalty_collaborator.entry((royalty_id, collaborator)).write(true);
            self.user_royalty_percentage.entry((royalty_id, collaborator)).write(percentage);
            self.royalty_collaborator_percentage_tracker.entry(royalty_id).write(percentage_tracker + percentage);
            self.royalty_owner_percentage_tacker.entry(royalty_id).write(owner_percentage_tracker - percentage);
            // add the collaborator to the royalty

        }

        // to add a list of collaborators
        // this will be used to add multiple collaborators all at once
        // it will take a list of collaborators and their percentages
        fn add_collaborators() {

        }

        fn get_balance(self: @ComponentState<TContractState>, user: ContractAddress) -> u256 {
            let balance = self.user_royalties.entry(user).read();

            balance
        }
    }
}