#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

action_ok propose proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clrfipro1", "title":"A simple one", "proposal_json":null}'

action_ko cleanvotes proposer1@active \
'{"proposer":"proposer1", "proposal_name":"clrfipro1", "max_count": 1}' \
'proposal_name must not exist anymore.'
