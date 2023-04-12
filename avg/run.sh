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

EXEC_FILE=${AVANTGRAPH_BINARIES}/ag-exec-multi-threaded

# Execute queries
for plan in ${AVANTGRAPH_PLANS}/*.plan.ipr; do
    queryid=$(echo ${plan} | grep -oP "[0-9]+(?=\.plan\.ipr)")
    # if (($queryid == 4)); then
    #     continue
    # fi
    outfile=${AVANTGRAPH_OUTPUT}/out_${queryid}.txt
    tracefile=${AVANTGRAPH_OUTPUT}/trace_${queryid}.txt

    echo 1 > /proc/sys/vm/drop_caches
    bufferPoolSizeOption=$([[ "$AVANTGRAPH_BRANCH" == "danny/vmcache" ]] && echo "--buffer-pool-size 8M" || echo "")
#    start=`date +%s.%N`
    (${EXEC_FILE} \
        $bufferPoolSizeOption \
        --planner none \
        --count \
        -M \
        --timeout=300 \
        --trace-filters=main \
        --trace-output="${tracefile}" \
        `#--verbose` \
        `#--dump-execution-state` \
        ${AVANTGRAPH_GRAPH}/ \
        ${plan} || true) |& tee ${outfile}
#    end=`date +%s.%N`

    threadcount="$(nproc) threads"
#    runtime=$(echo "$end - $start" | bc -l | awk '{printf "%f", $0}')
    runtime=$(cat "${tracefile}" | sed -E "/^\{\"name\": \"printQueryResults\"/!d ; s/^.*\"dur\": ([1-9][0-9]*).*$/\1 \/ 1000000/g" | bc -l | awk '{printf "%f", $0}')
    result=$(sed -E "/^Count [0-9]+$/!d ; s/^Count ([0-9]+)$/\1/g" ${outfile})
    if [[ "${result}" == "" ]]; then
        exit 1
    fi
    echo -e "AvantGraph-${AVANTGRAPH_BRANCH}\t${threadcount}\t${SF}\t${queryid}\t${runtime}\t${result}" >> ${RESULTS_FILE}
done
