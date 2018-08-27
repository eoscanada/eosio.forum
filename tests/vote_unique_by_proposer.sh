#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"simpleh1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok propose proposer2@active \
"{\"proposer\":\"proposer2\", \"proposal_name\":\"simpleh1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer1","proposal_name":"simpleh1","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer1","proposal_name":"simpleh1","vote":0,"vote_json":""}'

action_ok vote voter1@active \
'{"voter":"voter1","proposer":"proposer2","proposal_name":"simpleh1","vote":0,"vote_json":""}'

action_ok vote voter2@active \
'{"voter":"voter2","proposer":"proposer2","proposal_name":"simpleh1","vote":0,"vote_json":""}'
