# Intro

This repository contains the the Dockerfile and script to generate a Couchbase
server without having to use the Web UI.

# Building

```sh
docker build -t rugolini/couchbase-server-nosetup .
```

# Pulling the image

```sh
docker pull rugolini/couchbase-server-nosetup
```

# Running

## Run container

```sh
# Run container
docker run -d --name couchbase-server-nosetup \
  -p 8091-8093:8091-8093 \
  -p 11210:11210 \
  -p 4369:4369 \
  -p 21100-21299:21100-21299 \
  rugolini/couchbase-server-nosetup
```

## Run in cluster

### Create network

```sh
docker network create couchbase
```

### Create node1

```sh
# Create node1
docker run -ti --name node1.cluster \
  -p 8091-8093:8091-8093 \
  -p 11210:11210 \
  -p 4369:4369 \
  -p 21100-21299:21100-21299 \
  -h node1.cluster \
  --network=couchbase \
  rugolini/couchbase-server-nosetup
```

### joining node2 to node1

Rebalancing automatically

```sh
# Joining node1
docker run -ti --name node2.cluster \
  --network=couchbase \
  -h node2.cluster \
  -e CLUSTER_HOST=node1.cluster \
  -e CLUSTER_REBALANCE=true \
  rugolini/couchbase-server-nosetup
```

### joining node3 to node1

Rebalancing manually

```sh
# Joining node1
docker run -ti --name node3.cluster \
  --network=couchbase \
  -h node3.cluster \
  -e CLUSTER_HOST=node1.cluster \
  rugolini/couchbase-server-nosetup
```
