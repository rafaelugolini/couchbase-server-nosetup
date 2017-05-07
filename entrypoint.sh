#!/bin/bash

# Monitor mode (used to attach into couchbase entrypoint)
set -m
# Send it to background
/entrypoint.sh couchbase-server &

# Variable used to echo with steps
i=1
# Check if couchbase server is up
check_db() {
  curl --silent http://127.0.0.1:8091/pools > /dev/null
  echo $?
}
# Echo with
numbered_echo() {
  echo "[$i] $@"
  i=`expr $i + 1`
}


# Wait until it's ready
until [[ $(check_db) = 0 ]]; do
  >&2 numbered_echo "Waiting for Couchbase Server to be available"
  sleep 1
done

echo "# Couchbase Server Online"
echo "# Starting setup process"

# Reset steps
i=1
# Configure
numbered_echo "Setting up memory"
curl --silent http://127.0.0.1:8091/pools/default -d memoryQuota=${MEMORY_QUOTA} -d indexMemoryQuota=${INDEX_MEMORY_QUOTA} -d ftsMemoryQuota=${FTS_MEMORY_QUOTA}
numbered_echo "Setting up services"
curl --silent http://127.0.0.1:8091/node/controller/setupServices -d services="${SERVICES}"
numbered_echo "Setting up user credentials"
curl --silent http://127.0.0.1:8091/settings/web -d port=8091 -d username=${USERNAME} -d password=${PASSWORD} > /dev/null

# Attach to couchbase entrypoint
numbered_echo "Attaching to couchbase-server entrypoint"
fg 1
