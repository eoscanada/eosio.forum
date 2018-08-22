#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

proposal_json_not_object="[]"
proposal_json_too_long="{\\\\"a\\\\":\\\\"${CHARS_37500}\\\\"}"

action_ko propose proposer2@active \
'{"proposer":"proposer1", "proposal_name":"prpauth2", "title":"A simple one", "proposal_json":null}' \
'missing authority of proposer1'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":"${CHARS_1250}", \"proposal_json\":null}" \
'title should be less than 1024 characters long'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"a\", \"proposal_json\":\"${proposal_json_not_object}\"}" \
'proposal_json must be a JSON object (if specified)'

# FIXME: This passes while it should not, however, a second invocation yields CPU time exceed.
#        I suspect that parsing that amount of JSON data exceed the CPU time allowed to the transaction.
#        Will need to play with infinite CPU time to validate this hypothesis.
# action_ko propose proposer1@active \
# "{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"a\", \"proposal_json\":\"${proposal_json_too_long}\"}" \
# 'proposal_json should be shorter than 32768 bytes'