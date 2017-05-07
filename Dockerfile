FROM couchbase/server

COPY entrypoint.sh /config-entrypoint.sh

ENV MEMORY_QUOTA 256
ENV INDEX_MEMORY_QUOTA 256
ENV FTS_MEMORY_QUOTA 256

ENV SERVICES "kv,n1ql,index,fts"

ENV USERNAME "admin"
ENV PASSWORD "password"

ENTRYPOINT ["/config-entrypoint.sh"]
# ENTRYPOINT ["/bin/bash"]
