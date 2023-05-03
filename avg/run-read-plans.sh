#!/bin/bash

set -eu
set -o pipefail

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
cd ..

. scripts/import-vars.sh
. avg/vars.sh
ce="\033[0;31m$(tput bold)"
e="\033[0m$(tput sgr0)"

if ${AVANTGRAPH_REQUIRES_BUILD}; then
    echo -e "${ce}Error: Dependencies not build!${e}"
    exit 1
fi

EXEC_FILE=${AVANTGRAPH_BINARIES}/ag-exec

# Execute queries
for plan in avg/read-plans/*.plan; do
    queryid=$(basename $plan .plan)
    echo $queryid
    outfile=${AVANTGRAPH_OUTPUT}/out_${queryid}.txt
    tracefile=${AVANTGRAPH_OUTPUT}/trace_${queryid}.txt

    echo 1 > /proc/sys/vm/drop_caches
    (${EXEC_FILE} \
        --count \
        --timeout=300 \
        --trace-filters=main \
        --trace-output="${tracefile}" \
        ${AVANTGRAPH_GRAPH}/ \
        ${plan} || true) |& tee ${outfile}

    threadcount="$(nproc) threads"
    runtime=$(cat "${tracefile}" | sed -E "/^\{\"name\": \"execute\"/!d ; s/^.*\"dur\": ([1-9][0-9]*).*$/\1 \/ 1000000/g" | bc -l | awk '{printf "%f", $0}')
    result=$(sed -E "/^Count [0-9]+$/!d ; s/^Count ([0-9]+)$/\1/g" ${outfile})
    if [[ "${result}" == "" ]]; then
        exit 1
    fi
    echo -e "AvantGraph-${AVANTGRAPH_BRANCH}\t${threadcount}\t${SF}\t${queryid}\t${runtime}\t${result}" >> ${RESULTS_FILE}
done
