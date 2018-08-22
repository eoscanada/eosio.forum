#!/usr/bin/env bash

BROWN='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

printf "${BROWN}=========== Building eosio.forum ===========${NC}\n\n"

BUILD_SUFFIX=${1}
CORES=`getconf _NPROCESSORS_ONLN`

mkdir -p build${BUILD_SUFFIX}
pushd build${BUILD_SUFFIX} &> /dev/null
cmake ../
make -j${CORES}
popd &> /dev/null