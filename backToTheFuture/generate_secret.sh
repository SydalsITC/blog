#!/bin/bash

cat >secretVolume.yaml <<EOF
---
# contains libfaketime libraries
apiVersion: v1
kind: Secret
metadata:
  name: faketime-volume
type: Opaque
data:
  libfaketime.so.1: $(find /usr/lib* -name libfaketime.so.1 -exec base64 -w 0 {} \; )
EOF
