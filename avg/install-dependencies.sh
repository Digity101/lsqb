#!/bin/bash

set -eu
set -o pipefail

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ..

. scripts/import-vars.sh
. avg/vars.sh


if [[ ! -z $(which yum) ]]; then
    sudo yum update
    sudo yum install -y build-essential clang g++ gcc cmake ninja-build default-jdk-headless pkg-config python3-minimal llvm-12 llvm-12-dev zlib1g-dev valgrind ccache lld
elif [[ ! -z $(which apt) ]]; then
    sudo apt update
    sudo apt install -y build-essential clang g++ gcc cmake ninja-build default-jdk-headless pkg-config python3-minimal llvm-12 llvm-12-dev zlib1g-dev valgrind ccache lld
fi
