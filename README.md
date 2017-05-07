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

Running container

```sh
# Create mount point if needed
mkdir -p /opt/couchbase/var
# Run container
docker run -d --name couchbase-server-nosetup \
  -p 8091-8093:8091-8093 \
  -p 11210:11210 \
  -v /opt/couchbase/var:/opt/couchbase/var \
  rugolini/couchbase-server-nosetup
```
