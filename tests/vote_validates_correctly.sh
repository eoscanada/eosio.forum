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

vote_json_not_object="[]"
vote_json_too_long="{\\\\"a\\\\":\\\\"${CHARS_13000}\\\\"}"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"votevalcor4\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ko vote voter1@active \
'{"voter":"voter2","proposal_name":"votevalcor4","vote":0,"vote_json":""}' \
'missing authority of voter2'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposal_name\":\"notexist\",\"vote\":0,\"vote_json\":\"\"}" \
"proposal_name does not exist."

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposal_name\":\"votevalcor4\",\"vote\":0,\"vote_json\":\"${vote_json_not_object}\"}" \
'vote_json must be a JSON object (if specified).'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposal_name\":\"votevalcor4\",\"vote\":0,\"vote_json\":\"${vote_json_too_long}\"}" \
'vote_json should be shorter than 8192 bytes.'

println

## Expired proposal, within freeze period

info "Expired proposal, within freeze period"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"vtcorepwfp4\",\"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok expire proposer1@active \
'{"proposal_name":"vtcorepwfp4"}'

action_ko vote voter1@active \
'{"voter":"voter1","proposal_name":"vtcorepwfp4","vote":0,"vote_json":""}' \
'cannot vote on an expired proposal.'

println

## Expired proposal, after freeze period

info "Expired proposal, after freeze period"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"vtcorepofp4\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok expire proposer1@active \
'{"proposal_name":"vtcorepofp4"}'

msg "Waiting for freeze period expiration..."
sleep 3

action_ko vote voter1@active \
'{"voter":"voter1","proposal_name":"vtcorepofp4","vote":0,"vote_json":""}' \
'cannot vote on an expired proposal.'
