A simple forum, messaging and voting system for EOS
===================================================

[点击查看中文版](./README-cn.md)

This forum stores nothing in the in-RAM blockchain state. It allows authenticated
messages to go through, where they are visible in the transaction history of the chain.
Off-chain tools are needed to sort, display, aggregate and report on the outputs
of the various calls supported by the Forum contract.


Actions
=======

These are the available actions on this contract:
* `post` / `unpost` - post some content through the blockchain, nothing is stored on-chain
* `status` - post a small status line (like Twitter), stored on chain for quick retrieval
* `propose` / `unpropose` - store a proposal on-chain, to be voted on by people
  * `vote` - works alongside `propose`, to cast a vote on a given proposal

See the parameters for each [abi/forum.abi](the ABI file).


Sample use
----------

`post`:

```
cleos push action eosforumdapp post '{"poster": "YOURACCOUNT", "post_uuid":"somerandomstring", "content": "hello world", "reply_to_poster": "", "reply_to_post_uuid": "", "certify": false, "json_metadata": "{\"type\": \"chat\"}"}' -p YOURACCOUNT@active
```


`propose`:

```
cleos push action eosforumdapp propose '{"proposer": "proposeracct", "proposal_name": "theproposal", "title": "The title, for list views", "proposal_json": "{\"type\": \"bps-proposal-v1\", \"content\":\"This is the contents of the proposition\"}"}' -p YOURACCOUNT@active

# Review with:

cleos get table eosforumdapp proposeracct proposal
```

`vote`:

```
cleos push action eosforumdapp vote '{"voter": "YOURACCOUNT", "proposer": "proposeracct", "proposal_name": "theproposal", "proposition_hash": "[sha256 of title + proposal_json]", "vote": true, "vote_json": ""}' -p YOURACCOUNT@active
```

`status`:

```
cleos push action eosforumdapp status '{"account": "YOURACCOUNT", "content": "This is my status line"}' -p YOURACCOUNT@active

# Review with:

cleos get table eosforumdapp eosforumdapp status
```



Referendum structure proposals
==============================

`propose` a question to be voted with those parameters (`proposal_json` version #1)

```
proposer: eosio
proposal_name: thequestion
title: "EOSIO Referendum: The Question About ECAF and friends"  # An English string, to be shown in UIs
proposal_json: '{
  "type": "bps-proposal-v1",
  "content": "# Tally method\n\nThe tally method will be this and that, ... to the best of the active Block Producers's ability.\n\n# Voting period\n\nThe vote will stretch from the block it is submitted, and last for 1 million blocks.\n\n# Vote meaning\n\nA `vote` with value `true` means you adhere to the proposition.  A `vote` with value `false` means you do not adhere to the proposition.\n\n# The question\n\nDo you wish ECAF to become Santa Claus ?"
}'
```

The `vote` would look like:

```
voter: myaccount
proposer: eosio
proposal_name: thequestion
proposal_hash: acbdef112387abcefe123817238716acbdef12378912739812739acbd  # sha256 of "title + proposal_json" of proposal
vote: true
vote_json: ''
```

The rational behind `proposal_hash` is to confirm that the user was
presented with the right content. The UI should hash the content
displayed, in order to mitigate the risk of someone replacing its
proposition with some different contents and gathering on-chain votes
under false pretenses.

---

`proposal_json` structure #2:

```
proposal_json: '{
  "type": "bps-proposal-v2",
  "tally": "The tally method will be this and that, ... to the best of the active Block Producers's ability.",
  "voting_period": "The vote will stretch from the block it is submitted, and last for 1 million blocks.",
  "vote_meaning": "A `vote` with value `true` means you adhere to the proposition.  A `vote` with value `false` means you do not adhere to the proposition.",
  "question": "Do you wish ECAF to become Santa Claus ?"
}'
```

---

`proposal_json` structure #3:

```
proposal_json: '{
  "type": "bp-proposal-v3",
  "tally": "The tally method will be this and that, ... to the best of the active Block Producers's ability.",
  "voting_period": "The vote will stretch from the block it is submitted, and last for 1 million blocks.",
  "vote_meaning": "A `vote` with value `true` means you adhere to the proposition.  A `vote` with value `false` means you do not adhere to the proposition.",
  "question": {
    "en": "Do you wish ECAF becomes Santa Claus?",
    "fr": "Voulez-vous que l'ECAF devienne le père Noël ?"
  }
}'
```


Vocabulary for JSON structures
------------------------------

You can use any vocabulary you want when doing posts, proposals and
votes. However, by following some simple guidelines, you can simplify
your life and the life of those building UIs around these messages.

For all `json` prefixed or suffixed fields in `propose`, `vote` and
`post`, the `type` field determines a higher order protocol, and
determines what other sibling fields will be required.

### In a `propose`'s `proposal_json` field

* `type` is a required field to distinguish protocol.  See types in this section below.

* `question` means be the reference language question of a
  proposition.

* `content` is a Markdown document, detailing everything there is to know about the proposal (tally methods, time frame, references, required etc..)

* `ends_at_block_height` is an integer representing the last block
  height (inclusively) at which votes will be counted for this
  proposition. Any votes cast after this end height will not be
  counted.


### In a `vote`'s `vote_json` field

* `type` is optional. Defaults to `simple` if not present.

The `proposal_hash` is not enforced by the contract but might be
required by some proposals to consider a vote in the tally.

#### `type` values

* `simple` is the same as no `type` at all. The value of the vote is
  the boolean `vote` field of the _action_.


### In a `post`'s `json_metadata` field

* `type` is a required field to distinguish protocol.  See below for
  sample types

The following fields attempt at standardizing the meaning of certain
keys. If you specify your own `type`, you can define whatever you
want.

* `title` is a title that will be shown above a message, often used in
  clickable headlines. Similar to a Reddit post's title.

* `tags` is a list of strings, prefixed or not with a `#`.


#### `type` values

* `chat`, which is a simple chat, pushing a message out.

* `eos-bps-roll-call`, this is used within EOS Block Producers calls
  to indicate they are present.

* `eos-bps-emergency`, once **3** block producers send a message of
  this type within an hour, all block producers can trigger a wake-up
  alarm within 1h. Do not abuse this message to avoid alert
  fatigue. Example: serious vulnerability requires mitigation, serious
  network issues, immediate action required, etc..

* `eos-bps-notify`, once **7** block producers send a message of this type
  within an hour, other block producers can trigger a notification to
  get their attention in the **next 24h**. Example: new ECAF order requires
  attention.

* `eos-arbitration-order`, BPs can watch for known Arbitration forums
  accounts, and alert themselves of required action.  Further fields
  could be defined like a link to the PDF format order; a reference to
  a ready-made `eosio.msig` transaction proposition; etc..


Current rollout
===============

The latest version of this code lives on the `eosforumdapp` account on
the EOS mainnet.

Tools that initially integrated support for this contract are:
* [eosc](https://github.com/eoscanada/eosc) has a command-line interface
  implementation to submit posts and votes (in unreleased `master`).
* https://eostoolkit.io/forumpost allows you to post content through this contract.
* MyEOSKit already has special casing for the `post` actions. See
  [this transaction for example](https://www.myeoskit.com/?#/tx/c40e30d70ee92a0f57af475a828917851aa62b01bfbf395efae5c1a2b22068f0).




LICENSE
=======

MIT


Credits
=======

Original code and inspiration: Daniel Larimer
