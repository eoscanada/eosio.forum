#!/bin/bash -e

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd tests && pwd )"

freeze_period_constant_2s='constexpr static uint32_t FREEZE_PERIOD_IN_SECONDS = 2; // NEVER MERGE LIKE THIS'
freeze_period_constant_30d='constexpr static uint32_t FREEZE_PERIOD_IN_SECONDS = 30 \* 24 \* 60 \* 60;'

include_file="$ROOT/../include/forum.hpp"
include_backup_file="$ROOT/../include/forum.hpp.bak"

function stop() {
    echo "Reverting freeze period to it's previous value"
    if [[ -f "$include_backup_file" ]]; then
        cp "$include_backup_file" "$include_file"
        rm -rf "$include_backup_file" > /dev/null
    fi

    echo "Stopping container"
    sh "$ROOT/../stop.sh"
}

# Trap exit signal and closes docker instance
trap "stop" EXIT

echo "Replacing freeze period with fake one"
rm -rf "$include_backup_file" > /dev/null || true
sed -i.bak -e "s|$freeze_period_constant_30d|$freeze_period_constant_2s|g" "$include_file"

set +e
result=`cat $include_file | grep "${freeze_period_constant_2s}"`
exit_code=$?
if [[ $exit_code != 0 ]]; then
    echo "To correctly run all tests, the FREEZE_PERIOD_IN_SECONDS constant should be set to 2s."
    echo "Constant definition should look like this in 'include/forum.hpp' file:"
    echo ""
    echo "${freeze_period_constant_2s}"
    echo ""
    echo "It seems the auto-replacement of this script failed, please fix it!"
    exit 1
fi
set -e

echo "Building"
sh $ROOT/../build.sh

echo "Launching 'nodeos' instance"
sh $ROOT/../run.sh

echo "Testing"
sh $ROOT/all.sh

echo "Tests completed"
