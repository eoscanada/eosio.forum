Third iteration design
----------------------

Right now, we have tables like:

```
cleos get table eosforumdapp eoscanadacom proposal

code=eosforumdapp scope=eoscanadacom table=proposal
```

```
cleos get table eosforumdapp eosforumdapp status
```

New actions
-----------

 * `propose` - Create a new proposition

   Asserts:
     * `proposal_name` isn't `status`, NOR `proposal`... as to not confuse table names in the contract itself.

 * `vote` - Vote for a given proposition

    Fields: `proposer, proposal_name, voter, vote, vote_json`

    Asserts:
      * Proposals still exists

 * `unvote` - Unvote for a given proposition

   Fields: `proposer, proposal_name, voter`

   Notes:
    * Works even if proposal doesn't exist anymore


 * `unpropose` - Erase a proposal

    Fields: `proposer, proposal_name`

 * `cleanvotes`

    Fields: `proposer, proposal_name, count`

    Asserts:
     * The `proposer+proposal_name` doesn't exist anymore, or is expired.

Tables
------

#### Single Table

If a single table per proposer, we'd get something like:
```
code=eosforumdapp scope=eoscanadacom table=votes
```

We COULD use a secondary index, and create a new uint64.

**IMPORTANT!** CHECK with endianess of the lower/upper bound to search the secondary index.
```
 pk=proposal_name+voter proposal_name=allo vote=... vote_json...
 pk=proposal_name+voter proposal_name=allo
 pk=proposal_name+voter proposal_name=allo
 ```

We could delete rows by lower/upper proposal_name + name("").

#### Multi Table

One table per voters with NO Secondary index, only a primary key that is the `voter`. Excludes the possibility of using the `proposal` name as a `proposal_name`.

```
code=eosforumdapp scope=eoscanadacom table=[proposal_name]

pk=voter (name)
```