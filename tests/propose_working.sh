#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

## Normal

info "Normal"

action_ok propose proposer1@active \
"{\"proposer\":\"proposer1\", \"proposal_name\":\"propworkb5\", \"title\":\"A simple one\", \"proposal_json\":null, \"expires_at\":\"${EXPIRES_AT}\"}"

# Too hard to test `created_at` fields due to being set to `now`, so let's just check that proposal now exists
table_row proposal proposer1 '"proposal_name": "propworkb5", "title": "A simple one", "proposal_json": ""'
