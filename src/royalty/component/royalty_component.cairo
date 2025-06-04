



#[starknet::component]
pub mod Royalty {

    #[event]
    use audioverse::royalty::events::royalty_events::Event;
    use audioverse::royalty::events::royalty_events::{
        RoyaltyCreated, RoyaltyOwnershipUpdated, RoyaltyShareDistributed, WithdrawShare, CollaboratorAdded, RoyaltyOwnershipChangeRequested
    };
    use starknet::storage::{ StoragePointerReadAccess, StoragePointerWriteAccess, Map, StoragePathEntry,};
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
        pending_royalty_ownership_change: Map<u256, ContractAddress>, // royalty_id to new owner, used to track pending ownership changes
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

            self.emit(Event::RoyaltyCreated(RoyaltyCreated {
                royalty_id: royalty_id,
                creator: owner,
            }));
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

            self.emit(Event::CollaboratorAdded(CollaboratorAdded {
                royalty_id: royalty_id,
                collaborator: collaborator,
                percentage: percentage,
            }));
        }

        // to add a list of collaborators
        // this will be used to add multiple collaborators all at once
        // it will take a list of collaborators and their percentages
        fn add_collaborators(
            ref self: ComponentState<TContractState>,
            owner: ContractAddress,
            royalty_id: u256,
            collaborators: Array<ContractAddress>,
            collab_percentages: Array<u8>
        ) {
            // the add collaborator function will be used to add each collaborator and checks are been handled there 
            // so to avoid reduncancy, the add collaborator function will handle the checks
            assert(collaborators.len() == collab_percentages.len(), 'Mismatched arrays');
            assert(collaborators.len() > 0, 'Empty collaborator list');

            for i in 0..collaborators.len() {
                let collaborator = *collaborators.at(i);
                let percentage = *collab_percentages.at(i);
                self.add_collaborator(owner, royalty_id, collaborator, percentage);
            }
        }

        fn change_royalty_owner(ref self: ComponentState<TContractState>, owner: ContractAddress, royalty_id: u256, new_owner: ContractAddress) {
            assert!(royalty_id > 0, "Royalty ID must be greater than 0");
            assert!(royalty_id <= self.royalty_id_counter.read(), "Royalty ID does not exist");
            assert!(new_owner != owner, "New owner cannot be the same as the current owner");

            // check if the owner is the creator of the royalty
            let (creator, _, _) = self.royalties.entry(royalty_id).read();
            assert!(creator == owner, "Only the creator can change the owner");

            // update the royalty owner
            self.pending_royalty_ownership_change.entry(royalty_id).write(new_owner);

            // emit event
            self.emit(Event::RoyaltyOwnershipChangeRequested(RoyaltyOwnershipChangeRequested {
                royalty_id: royalty_id,
                new_owner: new_owner,
            }));
        }

        fn accept_royalty_ownership(ref self: ComponentState<TContractState>, new_owner: ContractAddress, royalty_id: u256) {
            assert!(royalty_id > 0, "Royalty ID must be greater than 0");
            assert!(royalty_id <= self.royalty_id_counter.read(), "Royalty ID does not exist");

            // check if the new owner is the one who requested the change
            let pending_new_owner = self.pending_royalty_ownership_change.entry(royalty_id).read();
            assert!(pending_new_owner == new_owner, "Only the new owner can accept the ownership");

            // get the current owner
            let (current_owner, funds, payment_token) = self.royalties.entry(royalty_id).read();

            // update the royalty owner
            self.royalties.entry(royalty_id).write((new_owner, funds, payment_token));

            // remove the pending ownership change
            // self.pending_royalty_ownership_change.entry(royalty_id).write(ContractAddress::new(felt252::zero());

            // remove the previous owner from the collaborator list
            self.is_royalty_collaborator.entry((royalty_id, current_owner)).write(false);
           
           // add the new owner to the collaborator list
            self.is_royalty_collaborator.entry((royalty_id, new_owner)).write(true);

            // emit event
            self.emit(Event::RoyaltyOwnershipUpdated(RoyaltyOwnershipUpdated {
                royalty_id: royalty_id,
                new_creator: new_owner,
                previous_creator: current_owner,
            }));
        }

        fn get_balance(self: @ComponentState<TContractState>, user: ContractAddress) -> u256 {
            let balance = self.user_royalties.entry(user).read();

            return balance;
        }
    }
}