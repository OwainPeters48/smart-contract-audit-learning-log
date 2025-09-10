# [M-1] Predictable Randomness via Timestamp in PizzaDrop

This was my first accepted finding on CodeHawks, submitted as part of a First Flights bounty hunt.  It's a Medium-severity issue (weak randomness) and a bit milestone in my auditing journeyy.


**What is the Issue?**
The `get_random_slice()` function assigns user rewards (100-500 APT) based only on `timestamp::now_microseconds()`.
Since timestamps are deterministic within each block, the randomness is predictable, and multiple users registering in the same block will receive identical rewards.

**Impact**
- Rewards are not truly random -> users can consistently receive identical outcomes.
- An attacker could attempt to game timing to maximise rewards
- Over time, this undermines fairness, centralises distribution, and damages project credibility.

**Proof of Concept**
A unit test demonstrated the determinism:
    - Two users registered back-to-back received identical reward amounts.
    - This shows randomness is fully dependent on the timestamp value, not user-specific entropy.

    ```move
    #[test(deployer = @pizza_drop, user1 = @0xabc, user2 = @0xdef, framework = @0x1)]
    fun test_timestamp_based_randomness(deployer: &signer, user1: &signer, user2: &signer, framework: &signer) acquires State, ModuleData {
        use aptos_framework::timestamp;

        timestamp::set_time_has_started_for_testing(framework);

        // Register two users back-to-back
        register_pizza_lover(deployer, signer::address_of(user1));
        register_pizza_lover(deployer, signer::address_of(user2));

        // Fetch assigned amounts
        let amt1 = get_claimed_amount(signer::address_of(user1));
        let amt2 = get_claimed_amount(signer::address_of(user2));

        // Assert identical slice amounts
        assert!(amt1 == amt2, 999);
    }
    ```

**Mitigation**
- Commit-Reveal scheme
    - Phase 1: Submit commitment = hash(address + nonce).
    - Phase 2: Reveal values -> randomness derived from commitment
- VRF oracle
    - Use Chainlink VRF or a similar service to generate unbiased, verifiable randomness.


**Judge Feedback**
The CodeHawks judge noted that the `get_random_slice` function should only be called by the owner via `register_pizza_lover()`.  Since the owner is trusted and will not deliberately choose a specific time for a new user to register, external attackers cannot manipulate the reward timing.
However, the judge agreed with the root cause: the random distribution is not completely random.  This issue was therefore classified as weak/predictable randomness (fairness flaw) rather than a direct manipulation vector.