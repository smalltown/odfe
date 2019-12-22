#!/bin/bash

echo "Update the open distro for ElasticSearch security configuration..."
kubectl -n elastic exec -t elasticsearch-data-0 -- /usr/bin/bash \
/usr/share/elasticsearch/plugins/opendistro_security/tools/securityadmin.sh \
-cd /usr/share/elasticsearch/plugins/opendistro_security/securityconfig \
-icl -nhnv \
-cacert /usr/share/elasticsearch/config/certs/root-ca.pem \
-cert /usr/share/elasticsearch/config/certs/kirk.pem \
-key /usr/share/elasticsearch/config/certs/kirk-key.pem
