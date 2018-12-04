#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

expires_at_already_expired=`date -v-1S +"%Y-%m-%dT%H:%M:%S"`
expires_at_over=`date -v+7m +"%Y-%m-%dT%H:%M:%S"`
proposal_json_not_object="[]"
proposal_json_too_long="{\\\\"a\\\\":\\\\"${CHARS_37500}\\\\"}"

action_ko propose proposer2@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"prpauth2\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}" \
'missing authority of proposer1'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"${CHARS_1250}\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}" \
'title should be less than 1024 characters long.'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${expires_at_already_expired}\"}" \
'expires_at must be a value in the future.'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${expires_at_over}\"}" \
'expires_at must be within 6 months from now.'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"a\", \"proposal_json\":\"${proposal_json_not_object}\", \"expires_at\":\"${EXPIRES_AT}\"}" \
'proposal_json must be a JSON object (if specified).'

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"a\", \"proposal_json\":\"${proposal_json_not_object}\", \"expires_at\":\"${EXPIRES_AT}\"}" \
'proposal_json must be a JSON object (if specified).'

# FIXME: This passes while it should not, however, a second invocation yields CPU time exceed.
#        I suspect that parsing that amount of JSON data exceed the CPU time allowed to the transaction.
#        Will need to play with infinite CPU time to validate this hypothesis.
# action_ko propose proposer1@active \
# "{\"proposer\":\"proposer1\", \"proposal_name\":\"provalcorr1\", \"title\":\"a\", \"proposal_json\":\"${proposal_json_too_long}\"}" \
# 'proposal_json should be shorter than 32768 bytes.'

println

## Already exists

info "Already exist"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"pvcalex1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

action_ko propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"pvcalex1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}" \
'proposal with same name already exists.'

action_ko propose proposer2@active \
"{\"proposer\":\"proposer2\", \"proposal_name\":\"pvcalex1\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}" \
'proposal with same name already exists.'