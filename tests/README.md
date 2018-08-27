## Tests

This folder contains a bunch of tests for this contract.

### Quick Start

 * Use `eos-bios boot` with a boot sequence that contains the following steps somewhere:

   ```
   - op: system.newaccount
    label: Create account eosioforum
    data:
        creator: eosio
        new_account: eosioforum
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create proposer1 account for eosioforum
    data:
        creator: eosio
        new_account: proposer1
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create proposer2 account for eosioforum
    data:
        creator: eosio
        new_account: proposer2
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create poster1 account for eosioforum
    data:
        creator: eosio
        new_account: poster1
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create poster2 account for eosioforum
    data:
        creator: eosio
        new_account: poster2
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create voter1 account for eosioforum
    data:
        creator: eosio
        new_account: voter1
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create proposer2 account for eosioforum
    data:
        creator: eosio
        new_account: voter2
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP

    - op: system.newaccount
    label: Create zzzzzzzzzzzz account for eosioforum
    data:
        creator: eosio
        new_account: zzzzzzzzzzzz
        pubkey: EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP
    ```

 * Import the following private key in your wallet: `5JpjqdhVCQTegTjrLtCSXHce7c9M8w7EXYZS7xC13jVFF4Phcrx` (this is the private key for the public one `EOS5MHPYyhjBjnQZejzZHqHewPWhGTfQWSVTWYEhDmJu4SXkzgweP`, of course, you can use your own pair).

 * Modify the grace period from its default 3 days to only 2 seconds. Indeed, to correctly tests stuff,
   since we don't control the actual clock of the blockchain, some of the tests in the test suite
   expects the grace period to be set to 2 seconds instead of the 3 days.

   To do this, open the `include/forum.hpp` and change the line (line 76 at time of writing):

   ```
   constexpr static uint32_t GRACE_PERIOD_IN_SECONDS = 3 * 24 * 60 * 60;
   ```

   to

   ```
   constexpr static uint32_t GRACE_PERIOD_IN_SECONDS = 2; // NEVER MERGE LIKE THIS! 3 * 24 * 60 * 60;
   ```

   The goal of adding `NEVER MERGE LIKE THIS!` is mainly to not forget to change back the value before
   doing an actual push to the git repository.

 * Compile and install the contract on the blockchain:

   ```
   ./build.sh && cleos set contract eosioforum `pwd` build/forum.wasm build/forum.abi
   ```

 * Run all the tests with `./tests/all.sh`

### Caveats

 * Tested only on Mac OS X.
 * Test cases needs to create unique resources (like proposal with unique name let's say).
