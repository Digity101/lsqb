#!/bin/bash

set -eu
set -o pipefail

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ..

. scripts/import-vars.sh
. avg/vars.sh

if ${AVANTGRAPH_REQUIRES_BUILD}; then
    exit 1
fi


bc="\033[0;33m$(tput bold)"
c="\033[0;33m"
ebc="\033[0m$(tput sgr0)"

loadtime=0
indextime=0
plantime=0


# Load graph
start=`date +%s.%N`

BASE=${IMPORT_DATA_DIR_PROJECTED_FK}
TARGET=${AVANTGRAPH_GRAPH}

echo "Planning.."
# Plan queries
start=`date +%s.%N`
## Copy queries
cp -r ${AVANTGRAPH_SRC_QUERIES}/*.cypher ${AVANTGRAPH_QUERIES}/
echo "Copied queries.."
# Generate plans
echo ${AVANTGRAPH_GRAPH}
for query in ${AVANTGRAPH_QUERIES}/*.cypher; do
    [[ "$(basename $query)" == not* || "$(basename $query)" == opt* ]] && continue
    echo "Planning ${query}"
    startq=`date +%s.%N`
    ${AVANTGRAPH_BINARIES}/ag-plan --query-type=cypher --physical=false --planner=binary --count ${AVANTGRAPH_GRAPH} ${query} > ${AVANTGRAPH_PLANS}/$(basename ${query} .cypher).plan.ipr
    endq=`date +%s.%N`
    plantimeq=$(echo "$endq - $startq" | bc -l | awk '{printf "%f", $0}')
    echo -e "${c}- Plan time Query ${query} : ${plantimeq}${ebc}" 
done

end=`date +%s.%N`
plantime=$(echo "$end - $start" | bc -l | awk '{printf "%f", $0}')

# Report times
echo -e "${c}- Plan time : ${plantime}${ebc}"
