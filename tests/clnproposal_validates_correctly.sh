#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

info "Not expired"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clrfiprone4\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ko clnproposal proposer1@active \
'{"proposal_name":"clrfiprone4", "max_count": 1}' \
'proposal must not exist or be expired for at least 30 days prior to running clnproposal.'

println

info "Expired, within freeze period"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clrfiprogp4\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${EXPIRES_AT}\"}"

action_ok expire proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"clrfiprogp4\"}"

action_ko clnproposal proposer1@active \
'{"proposal_name":"clrfiprogp4", "max_count": 1}' \
'proposal must not exist or be expired for at least 30 days prior to running clnproposal.'
