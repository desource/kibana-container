#!/usr/bin/env bash
set -eux

KIBANA_VERSION=4.5.4
KIBANA_SHA1=dba409384fe36f1b5ad20e7dd7e6efacdc09ed11

BASE=$PWD
SRC=$PWD/src
OUT=$PWD/out
ROOTFS=$PWD/rootfs

mkdir -p $OUT $ROOTFS/opt/kibana
cd $BASE
curl -sOL https://download.elastic.co/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz
echo "$KIBANA_SHA1  kibana-$KIBANA_VERSION-linux-x64.tar.gz" | sha1sum -c
tar -xf kibana-$KIBANA_VERSION-linux-x64.tar.gz -C $ROOTFS/opt/kibana --strip-components 1

rm -rf $ROOTFS/opt/kibana/node $ROOTFS/opt/kibana/bin
chown -R root:root $ROOTFS/opt
chown -R nobody:root $ROOTFS/opt/kibana/optimize

cd $ROOTFS
tar -cf $OUT/rootfs.tar .


cat <<EOF > $OUT/version
${KIBANA_VERSION}
EOF

cat <<EOF > $OUT/Dockerfile
FROM quay.io/desource/nodejs:6

ADD rootfs.tar /

EXPOSE 5601

USER nobody

WORKDIR /opt/kibana

ENTRYPOINT ["/usr/bin/node", "src/cli"]

EOF

