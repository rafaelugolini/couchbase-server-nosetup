#!/bin/bash

# Monitor mode (used to attach into couchbase entrypoint)
set -m
# Send it to background
/entrypoint.sh couchbase-server &

# Check if couchbase server is up
check_db() {
  curl --silent http://127.0.0.1:8091/pools > /dev/null
  echo $?
}

# Variable used in echo
i=1
# Echo with
numbered_echo() {
  echo "[$i] $@"
  i=`expr $i + 1`
}

# Parse JSON and get nodes from the cluster
read_nodes() {
  cmd="import sys,json;"
  cmd="${cmd} print(','.join([node['otpNode']"
  cmd="${cmd} for node in json.load(sys.stdin)['nodes']"
  cmd="${cmd} ]))"
  python -c "${cmd}"
}

# Wait until it's ready
until [[ $(check_db) = 0 ]]; do
  >&2 numbered_echo "Waiting for Couchbase Server to be available"
  sleep 1
done

echo "# Couchbase Server Online"
echo "# Starting setup process"

HOSTNAME=`hostname -f`

# Reset steps
i=1
# Configure
numbered_echo "Initialize the node"
curl --silent "http://${HOSTNAME}:8091/nodes/self/controller/settings" \
  -d path="/opt/couchbase/var/lib/couchbase/data" \
  -d index_path="/opt/couchbase/var/lib/couchbase/data"

numbered_echo "Setting hostname"
curl --silent "http://${HOSTNAME}:8091/node/controller/rename" \
  -d hostname=${HOSTNAME}

if [[ ${CLUSTER_HOST} ]];then
  numbered_echo "Joining cluster ${CLUSTER_HOST}"
  curl --silent -u ${USERNAME}:${PASSWORD} \
    "http://${CLUSTER_HOST}:8091/controller/addNode" \
    -d hostname="${HOSTNAME}" \
    -d user="${USERNAME}" \
    -d password="${PASSWORD}" \
    -d services="${SERVICES}" > /dev/null

  if [[ ${CLUSTER_REBALANCE} ]]; then
    # "Unexpected server error without the sleep 2
    sleep 2
    numbered_echo "Retrieving nodes"
    known_nodes=$(
      curl --silent -u ${USERNAME}:${PASSWORD} http://${CLUSTER_HOST}:8091/pools/default | read_nodes
    )

    numbered_echo "Rebalancing cluster"
    curl -u ${USERNAME}:${PASSWORD} \
      "http://${CLUSTER_HOST}:8091/controller/rebalance" \
      -d knownNodes="${known_nodes}"
  fi

else
  numbered_echo "Setting up memory"
  curl --silent "http://${HOSTNAME}:8091/pools/default" \
    -d memoryQuota=${MEMORY_QUOTA} \
    -d indexMemoryQuota=${INDEX_MEMORY_QUOTA} \
    -d ftsMemoryQuota=${FTS_MEMORY_QUOTA}

  numbered_echo "Setting up services"
  curl --silent "http://${HOSTNAME}:8091/node/controller/setupServices" \
    -d services="${SERVICES}"

  numbered_echo "Setting up user credentials"
  curl --silent "http://${HOSTNAME}:8091/settings/web" \
    -d port=8091 \
    -d username=${USERNAME} \
    -d password=${PASSWORD} > /dev/null

fi
# Attach to couchbase entrypoint
numbered_echo "Attaching to couchbase-server entrypoint"
fg 1
