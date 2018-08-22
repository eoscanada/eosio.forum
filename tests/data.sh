#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

## Add few more proposals/votes for easier development purposes

### Proposals

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"a1", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"z1", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"51", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"1a", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"1z", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"11", "title":"A simple one", "proposal_json":null}'

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"zzzzzzzzzzzz", "title":"A simple one", "proposal_json":null}'

### Votes

#### Voter1

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"a1","proposal_hash":"","vote":0,"vote_json":""}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"z1","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"51","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"1z","proposal_hash":"","vote":1,"vote_json":""}'

#### Voter2

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"a1","proposal_hash":"","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"z1","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"51","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"1a","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"11","proposal_hash":"","vote":1,"vote_json":""}'

#### zzzzzzzzzzzz (Voter)

action_ok vote zzzzzzzzzzzz@active \
'{"voter":"zzzzzzzzzzzz","proposer":"proposer1","proposal_name":"a1","proposal_hash":"","vote":1,"vote_json":""}'

action_ok vote zzzzzzzzzzzz@active \
'{"voter":"zzzzzzzzzzzz","proposer":"proposer1","proposal_name":"z1","proposal_hash":"","vote":1,"vote_json":""}'
