#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

###
# **Important**
#
# Usually, the freeze period before cleaning proposal is 30 days. The tests
# in this file expect that the freeze period is set to 2s only!
#
# You will need to modify the source code of the contract before running
# those tests!
#

## No votes

info "No vote"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwonv1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok expire proposer1@active \
'{"proposal_name":"clvotwonv1"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwonv1", "max_count": 1000}'

println

## One vote

info "One vote"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwo1v1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"clvotwo1v1","vote":0,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"clvotwo1v1"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwo1v1", "max_count": 1}'

table_row vote ${CONTRACT} '!"proposal_name": "clvotwo1v1", "voter": "voter1"'

println

## Multi vote, one pass

info "Multi vote (one pass)"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwonv1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"clvotwonv1","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposal_name":"clvotwonv1","vote":1,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"clvotwonv1"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clvotwonv1", "max_count": 1000}'

table_row vote ${CONTRACT} '!"proposal_name": "clvotwonv1", "voter": "voter1"'
table_row vote ${CONTRACT} '!"proposal_name": "clvotwonv1", "voter": "voter2"'

println

## Multi vote, multi pass

info "Multi vote (multi pass)"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwonvmp2\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"clvotwonvmp2","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposal_name":"clvotwonvmp2","vote":1,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"clvotwonvmp2"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwonvmp2", "max_count": 1}'

table_row vote ${CONTRACT} '!"proposal_name": "clvotwonvmp2", "voter": "voter1"'
table_row vote ${CONTRACT} '"proposal_name": "clvotwonvmp2", "voter": "voter2"'

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwonvmp2", "max_count": 1}'

table_row vote ${CONTRACT} '!"proposal_name": "clvotwonvmp2", "voter": "voter1"'
table_row vote ${CONTRACT} '!"proposal_name": "clvotwonvmp2", "voter": "voter2"'

println

# Proposal removal, one pass

info "Proposal removal, one pass"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwo1eop\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"clvotwo1eop","vote":0,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"clvotwo1eop"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwo1eop", "max_count": 1}'

table_row proposal ${CONTRACT} '!"proposal_name": "clvotwo1eop"'

println

## Proposal removal, multi pass

info "Proposal removal, multi pass"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clvotwo1emp2\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"clvotwo1emp2","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposal_name":"clvotwo1emp2","vote":0,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"clvotwo1emp2"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwo1emp2", "max_count": 1}'

table_row proposal ${CONTRACT} '"proposal_name": "clvotwo1emp2"'

action_ok clnproposal proposer1@active \
'{"proposal_name":"clvotwo1emp2", "max_count": 1}'

table_row proposal ${CONTRACT} '!"proposal_name": "clvotwo1emp2"'
