#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"uvotvalco3\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ko unvote voter1@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"uvotvalco3"}' \
'missing authority of voter2'

action_ko unvote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"notexist\"}" \
"proposal_name does not exist under proposer's scope."

action_ko unvote voter2@active \
"{\"voter\":\"voter2\",\"proposer\":\"proposer1\",\"proposal_name\":\"uvotvalco3\"}" \
'no vote exists for this proposal_name/voter pair.'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"uvotvalco3","vote":0,"vote_json":""}'

action_ok expire proposer1@active \
'{"proposer":"proposer1", "proposal_name":"uvotvalco3"}'

action_ko unvote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"uvotvalco3"}' \
'cannot unvote on an expired proposal within its grace period.'
