#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

vote_json_not_object="[]"
vote_json_too_long="{\\\\"a\\\\":\\\\"${CHARS_13000}\\\\"}"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"votevalcor4\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ko vote voter1@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"votevalcor4","vote":0,"vote_json":""}' \
'missing authority of voter2'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"notexist\",,\"vote\":0,\"vote_json\":\"\"}" \
"proposal_name does not exist under proposer's scope."

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor4\",,\"vote\":0,\"vote_json\":\"${vote_json_not_object}\"}" \
'vote_json must be a JSON object (if specified).'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor4\",,\"vote\":0,\"vote_json\":\"${vote_json_too_long}\"}" \
'vote_json should be shorter than 8192 bytes.'

action_ok expire proposer1@active \
'{"proposer":"proposer1", "proposal_name":"votevalcor4"}'

action_ko vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"votevalcor4","vote":0,"vote_json":""}' \
'cannot vote on an expired proposal.'