#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

expires_at_custom=`date -u -v+1m +"%Y-%m-%dT%H:%M:%S"`

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"exprowor2\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\": \"${expires_at_custom}\"}"

table_row proposal proposer1 "${expires_at_custom}"

action_ok expire proposer1@active \
'{"proposer":"proposer1", "proposal_name":"exprowor2"}'

# Checking for the actual `now()` value is too error-prone, so we just validate that the custom `expires_at` is not there anymore
table_row proposal proposer1 "!${expires_at_custom}"
