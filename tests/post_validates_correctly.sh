#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; source "${ROOT}/library.sh"

json_metadata_not_object="[]"
json_metadata_too_long="{\\\\"a\\\\":\\\\"${CHARS_13000}\\\\"}"

action_ko post poster2@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"1\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'missing authority of poster1'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"1\", \"content\":\"\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'content should be longer than 0 character.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"1\", \"content\":\"${CHARS_13000}\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'content should be less than 10 KB.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'post_uuid should be longer than 0 character.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"${CHARS_250}\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'post_uuid should be shorter than 128 characters.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"a\", \"content\":\"a\", \"reply_to_poster\":\"notexist\", \"reply_to_post_uuid\":\"b\", \"certify\": true, \"json_metadata\":\"\"}" \
'reply_to_poster must be a valid account.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"a\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"\", \"certify\": true, \"json_metadata\":\"\"}" \
'reply_to_post_uuid should be longer than 0 character.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"a\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"${CHARS_250}\", \"certify\": true, \"json_metadata\":\"\"}" \
'reply_to_post_uuid should be shorter than 128 characters.'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"a\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"any\", \"certify\":true, \"json_metadata\":\"${json_metadata_not_object}\"}" \
'json_metadata must be a JSON object (if specified).'

action_ko post poster1@active \
"{\"poster\":\"poster1\", \"post_uuid\":\"a\", \"content\":\"a\", \"reply_to_poster\":\"poster2\", \"reply_to_post_uuid\":\"any\", \"certify\": true, \"json_metadata\":\"${json_metadata_too_long}\"}" \
'json_metadata should be shorter than 8192 bytes.'