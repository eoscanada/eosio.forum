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

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"unvworkb2\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"unvworkb2","vote":0,"vote_json":""}'

table_row vote ${CONTRACT} '"proposal_name": "unvworkb2", "voter": "voter1", "vote": 0, "vote_json": ""'

action_ok unvote voter1@active \
'{"voter":"voter1","proposal_name":"unvworkb2"}'

table_row vote ${CONTRACT} '!"proposal_name": "unvworkb2", "voter": "voter1", "vote": 0, "vote_json": ""'

println

info "Unvote expired, after freeze period"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"unvworkbegp1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposal_name":"unvworkbegp1","vote":0,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposal_name":"unvworkbegp1"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ok unvote voter1@active \
'{"voter":"voter1","proposal_name":"unvworkbegp1"}'
