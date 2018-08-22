#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

## No votes

info "No vote"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1", "title":"A simple one", "proposal_json":null}'

action_ok unpropose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1"}'

action_ok cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1", "max_count": 1000}'

println

## One vote

info "One vote"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwo1v1", "title":"A simple one", "proposal_json":null}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"clvotwo1v1","proposal_hash":"","vote":0,"vote_json":""}'

action_ok unpropose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwo1v1"}'

action_ok cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwo1v1", "max_count": 1}'

table_row vote proposer1 '!"proposal_name": "clvotwo1v1", "voter": "voter1"'

println

## Multi vote, one pass

info "Multi vote (one pass)"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1", "title":"A simple one", "proposal_json":null}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"clvotwonv1","proposal_hash":"","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"clvotwonv1","proposal_hash":"","vote":1,"vote_json":""}'

action_ok unpropose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1"}'

action_ok cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1", "max_count": 1000}'

table_row vote proposer1 '!"proposal_name": "clvotwonv1", "voter": "voter1"'
table_row vote proposer1 '!"proposal_name": "clvotwonv1", "voter": "voter2"'

println

## Multi vote, multi pass

info "Multi vote (multi pass)"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonvmp1", "title":"A simple one", "proposal_json":null}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"clvotwonvmp1","proposal_hash":"","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"clvotwonvmp1","proposal_hash":"","vote":1,"vote_json":""}'

action_ok unpropose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonvmp1"}'

action_ok cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonvmp1", "max_count": 1}'

table_row vote proposer1 '!"proposal_name": "clvotwonvmp1", "voter": "voter1"'
table_row vote proposer1 '"proposal_name": "clvotwonvmp1", "voter": "voter2"'

action_ok cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonvmp1", "max_count": 1}'

table_row vote proposer1 '!"proposal_name": "clvotwonvmp1", "voter": "voter1"'
table_row vote proposer1 '!"proposal_name": "clvotwonvmp1", "voter": "voter2"'