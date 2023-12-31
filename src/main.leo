program priv_pub_m_token_test.aleo {
    // note on v2 -- add settings in the chain
    mapping account: address => u64;

    record m_token {
        owner: address,
        amount: u64,
    }

    /* Mint */
    transition mint_public(public receiver: address, public amount: u64) {
        // Only aleo1asu88azw3uqud282sll23wh3tvmvwjdz5vhvu2jwyrdwtgqn5qgqetuvr6 can mint, nerds
        assert_eq(self.caller, aleo1asu88azw3uqud282sll23wh3tvmvwjdz5vhvu2jwyrdwtgqn5qgqetuvr6);
        return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver: address, public amount: u64) {
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition mint_private(receiver: address, amount: u64) -> m_token {
        // Only aleo1asu88azw3uqud282sll23wh3tvmvwjdz5vhvu2jwyrdwtgqn5qgqetuvr6 can mint, nerds
        assert_eq(self.caller, aleo1asu88azw3uqud282sll23wh3tvmvwjdz5vhvu2jwyrdwtgqn5qgqetuvr6);
        return m_token {
            owner: receiver,
            amount: amount,
        };
    }

    /* Transfer */
    transition transfer_public(public receiver: address, public amount: u64) {
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);

        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_private(sender: m_token, receiver: address, amount: u64) -> (m_token, m_token) {
        let difference: u64 = sender.amount - amount;

        let remaining: m_token = m_token {
            owner: sender.owner,
            amount: difference,
        };

        let transferred: m_token = m_token {
            owner: receiver,
            amount: amount,
        };

        return (remaining, transferred);
    }

    transition transfer_private_to_public(sender: m_token, public receiver: address, public amount: u64) -> m_token {
        let difference: u64 = sender.amount - amount;

        let remaining: m_token = m_token {
            owner: sender.owner,
            amount: difference,
        };

        return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver: address, public amount: u64) {
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_public_to_private(public receiver: address, public amount: u64) -> m_token {
        let transferred: m_token = m_token {
            owner: receiver,
            amount: amount,
        };

        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender: address, public amount: u64) {
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }
    

    
}
