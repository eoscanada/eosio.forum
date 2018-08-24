#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

## No proposal hash

info "No proposal hash"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"votworkwoph1", "title":"A simple one", "proposal_json":null}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"votworkwoph1","proposal_hash":"","vote":0,"vote_json":""}'

table_row vote proposer1 '"proposal_name": "votworkwoph1", "proposal_hash": "", "voter": "voter1", "vote": 0, "vote_json": ""'

println

## With proposal hash

info "With proposal hash"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"votworkwph3", "title":"A simple one", "proposal_json":null}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"votworkwph3","proposal_hash":"31c28bb8e8e942211eafd89f3f8d75955d42f0e8dd7edb80f7c0899fbe128505","vote":0,"vote_json":""}'

table_row vote proposer1 '"proposal_name": "votworkwph3", "proposal_hash": "31c28bb8e8e942211eafd89f3f8d75955d42f0e8dd7edb80f7c0899fbe128505", "voter": "voter1", "vote": 0, "vote_json": ""'

println