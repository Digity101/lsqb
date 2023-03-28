AVANTGRAPH_BRANCH=${AVANTGRAPH_BRANCH:-develop}
AVANTGRAPH_DIR=`pwd`/avg/scratch/${AVANTGRAPH_BRANCH}
AVANTGRAPH_GRAPH=${AVANTGRAPH_DIR}/graph-data-${SF}
AVANTGRAPH_CHECKSUMS=${AVANTGRAPH_DIR}/checksums
AVANTGRAPH_QUERIES=${AVANTGRAPH_DIR}/queries
AVANTGRAPH_PLANS=${AVANTGRAPH_DIR}/plans
AVANTGRAPH_OUTPUT=${AVANTGRAPH_DIR}/output
AVANTGRAPH_BINARIES=`pwd`/avg/avantgraph-binaries/${AVANTGRAPH_BRANCH}
AVANTGRAPH_LOAD_SCRIPT=${AVANTGRAPH_BINARIES}/contrib/import_csv.py

AVANTGRAPH_SRC_QUERIES=`pwd`/avg/queries
# Set to 1 for using cache, 0 for no cache.
AVANTGRAPH_CACHE=1

RESULTS_FILE=`pwd`/results/results.csv

AVANTGRAPH_CONTAINER=lsqb-avg # TODO: make implementation with docker container

AVANTGRAPH_REQUIRES_BUILD=$([ -f ${AVANTGRAPH_BINARIES}/contrib/import_csv.py ] && \
        [ -f ${AVANTGRAPH_BINARIES}/ag-load-graph ] && \
        [ -f ${AVANTGRAPH_BINARIES}/ag-index ] && \
        [ -f ${AVANTGRAPH_BINARIES}/ag-plan ] && \
        [ -f ${AVANTGRAPH_BINARIES}/ag-exec-multi-threaded ] && echo "false" || echo "true")
