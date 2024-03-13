use starknet::ContractAddress;

#[starknet::interface]
trait IGladiethers<TContractState> {
    fn ChangeAddressTrust(
        ref self: TContractState, contract_address: ContractAddress, trust_flag: bool
    );
    fn Gladiethers(ref self: TContractState);
    fn setPartner(ref self: TContractState, contract_partner: ContractAddress);
    fn joinArena(ref self: TContractState) -> bool;
    fn enter(ref self: TContractState, gladiator: ContractAddress);
}

#[starknet::contract]
mod Gladiethers {
    use core::box::BoxTrait;
    use core::clone::Clone;
    use core::serde::Serde;
    use core::traits::IndexView;
    use core::traits::Into;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use core::dict::Felt252DictTrait;
    use starknet::ContractAddress;
    use core::num::traits::Zero;
    use core::array::ArrayTrait;
    use core::dict::Felt252Dict;
    use starknet::{
        get_block_number, get_caller_address, get_contract_address, get_block_timestamp,
        get_tx_info, get_block_info
    };

    #[storage]
    struct Storage {
        stored_data: u128,
        owner: ContractAddress,
        partner: ContractAddress,
        trustedContracts: Felt252Dict<bool>,
        gladiatorToCooldown: Felt252Dict<u64>,
        gladiatorToQueuePosition: Felt252Dict<u32>,
        queue: Array::<ContractAddress>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        FightEvent: FightEvent,
    }

    #[derive(Drop, starknet::Event)]
    struct FightEvent {
        #[key]
        g1: ContractAddress,
        g2: ContractAddress,
        random: u128,
        fightPower: u128,
        g1Power: u128,
    }

    #[abi(embed_v0)]
    impl Gladiethers of super::IGladiethers<ContractState> {
        fn ChangeAddressTrust(
            ref self: ContractState, contract_address: ContractAddress, trust_flag: bool
        ) {
            let address = get_caller_address();
            let mut trusted = self.trustedContracts.read();
            assert!(
                address == self.owner.read() || trusted.get(address.try_into().unwrap()),
                "Only owner or trusted contracts can call this function"
            );
            assert!(contract_address != address, "Can't change trust for yourself");
            trusted.insert(contract_address.try_into().unwrap(), trust_flag);
            self.trustedContracts.write(trusted);
        }
        fn Gladiethers(ref self: ContractState) {
            self.owner.write(get_caller_address());
        }

        fn setPartner(ref self: ContractState, contract_partner: ContractAddress) {
            self.partner.write(contract_partner)
        }

        fn joinArena(ref self: ContractState) -> bool {
            //the address depositing ether must match the address of the caller of this contract
            let tx = get_tx_info();
            let origin = tx.unbox().account_contract_address;
            //unsure the tip is the transaction value
            let value = tx.unbox().tip;
            assert!(
                get_caller_address() == origin && value >= 10,
                "Only the origin can call this function"
            );
            let mut gladiatorToQueuePosition = self.gladiatorToQueuePosition.read();
            let mut queue = self.queue.read();
            if self
                .queue
                .read()
                .len() > gladiatorToQueuePosition
                .get(get_caller_address().try_into().unwrap()) { // if queue
            //     .get(
            //         gladiatorToQueuePosition.get(get_caller_address().try_into().unwrap())
            //     ) == get_caller_address()
            //     .try_into()
            //     .unwrap() {}
            }
            return false;
        }
        fn enter(ref self: ContractState, gladiator: ContractAddress) {
            let mut gladiatorCooldowns = self.gladiatorToCooldown.read();
            gladiatorCooldowns.insert(gladiator.try_into().unwrap(), get_block_timestamp() + 86400);
            let mut queue = self.queue.read();
            queue.append(gladiator);
            let queue_len = queue.len();
            self.queue.write(queue);
            let mut gladiatorToQueuePosition = self.gladiatorToQueuePosition.read();
            gladiatorToQueuePosition.insert(gladiator.try_into().unwrap(), queue_len);
        }
    }
}
