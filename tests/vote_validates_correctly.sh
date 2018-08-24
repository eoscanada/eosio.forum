#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

vote_json_not_object="[]"
vote_json_too_long="{\\\\"a\\\\":\\\\"${CHARS_13000}\\\\"}"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"votevalcor2", "title":"A simple one", "proposal_json":null}'

action_ko vote voter1@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"votevalcor2","proposal_hash":"","vote":0,"vote_json":""}' \
'missing authority of voter2'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"notexist\",\"proposal_hash\":\"\",\"vote\":0,\"vote_json\":\"\"}" \
"proposal_name does not exist under proposer's scope."

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor2\",\"proposal_hash\":\"${CHARS_250}\",\"vote\":0,\"vote_json\":\"\"}" \
'proposal_hash should be 64 hexadecimals characters long (sha256 format).'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor2\",\"proposal_hash\":\"21c28bb8e8e842211eafd89f3f8d85955d42f0e8dd7edb80f7c0899fbe128505\",\"vote\":0,\"vote_json\":\"\"}" \
'provided proposal_hash does not match actual computed proposal_hash.'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor2\",\"proposal_hash\":\"\",\"vote\":0,\"vote_json\":\"${vote_json_not_object}\"}" \
'vote_json must be a JSON object (if specified).'

action_ko vote voter1@active \
"{\"voter\":\"voter1\",\"proposer\":\"proposer1\",\"proposal_name\":\"votevalcor2\",\"proposal_hash\":\"\",\"vote\":0,\"vote_json\":\"${vote_json_too_long}\"}" \
'vote_json should be shorter than 8192 bytes.'