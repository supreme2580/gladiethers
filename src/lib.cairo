#[starknet::interface]
trait IGladiethers<TContractState> {
    fn set(ref self: TContractState, x: u128);
    fn get(self: @TContractState) -> u128;
    fn main(ref self: TContractState);
    fn ChangeAddressTrust(
        ref self: TContractState, contract_address: starknet::ContractAddress, trust_flag: bool
    );
    fn Gladiethers(ref self: TContractState);
    fn setPartner(ref self: TContractState, contract_partner: starknet::ContractAddress);
}

#[starknet::contract]
mod Gladiethers {
    use core::clone::Clone;
    use core::serde::Serde;
    use core::traits::IndexView;
    use core::traits::Into;
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use core::dict::Felt252DictTrait;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use core::num::traits::Zero;
    use core::array::ArrayTrait;
    use core::dict::Felt252Dict;

    #[storage]
    struct Storage {
        stored_data: u128,
        owner: ContractAddress,
        partner: ContractAddress,
        trustedContracts: Felt252Dict<bool>,
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
        fn set(ref self: ContractState, x: u128) {
            self.stored_data.write(x);
        }
        fn get(self: @ContractState) -> u128 {
            self.stored_data.read()
        }
        fn main(ref self: ContractState) {
            let mut m_Owner: ContractAddress = self.owner.read();
            let mut partner: ContractAddress = self.partner.read();
            let mut gladiatorToPower: Array::<u128> = ArrayTrait::<u128>::new();
            let mut gladiatorToCooldown: Array::<u128> = ArrayTrait::<u128>::new();
            let mut gladiatorToLuckyPoints: Array::<u128> = ArrayTrait::<u128>::new();
            let mut gladiatorToQueuePosition: Array::<u128> = ArrayTrait::<u128>::new();
            let mut trustedContracts: Array::<u32> = ArrayTrait::<u32>::new();
            let mut m_OwnerFees: u128 = 0;
            let mut kingGladiator: u128 = 0;
            let mut kingGladiatorFounder: u128 = 0;
            let mut queue: Array::<ContractAddress> = ArrayTrait::<ContractAddress>::new();
            let mut started: bool = false;
        }

        fn ChangeAddressTrust(
            ref self: ContractState, contract_address: ContractAddress, trust_flag: bool
        ) {
            let address = get_caller_address();
            let mut trusted = self.trustedContracts.clone().read();
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
    }
}
