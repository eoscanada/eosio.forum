#!/usr/bin/env bash

set -e

TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for var in `ls $TEST_DIR`; do
    if [[ $var == "all.sh" || $var == "data.sh" || $var == local_*.sh || $var == "library.sh" || $var == "README.md" ]]; then
        continue
    fi

    echo "Running $var"
    bash "${TEST_DIR}/$var"
    echo ""
done
