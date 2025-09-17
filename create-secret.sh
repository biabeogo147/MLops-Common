#!/bin/bash

kubectl create secret generic name-secret \
  --from-literal=NAME_VARIABLE="" \
  -n namespace \
  --dry-run=client -o yaml | kubectl apply -f -