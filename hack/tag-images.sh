#!/bin/bash
set -euo pipefail

REPODIR="$(dirname "$0")/.."
RELEASE_PREFIX="$(cat "${REPODIR}/release-prefix")"
RELEASE_TAG="v${RELEASE_PREFIX}-$(cat "${REPODIR}/release-date")"

echo "The release tag is ${RELEASE_TAG}"

if ! which oc &> /dev/null; then
  echo "ERROR: the oc command is required for this script."
  exit 1
fi

if ! oc get istag -n hypershift-toolkit ibm-roks-control-plane-operator:${RELEASE_TAG} &> /dev/null; then
  echo "Tagging control-plane-operator image with ${RELEASE_TAG}"
  oc tag registry.ci.openshift.org/hypershift-toolkit/ibm-roks-${RELEASE_PREFIX}:control-plane-operator \
        ibm-roks-control-plane-operator:${RELEASE_TAG} \
        -n hypershift-toolkit
else
  echo "control-plane-operator image tag ${RELEASE_TAG} already exists"
fi

if ! oc get istag -n hypershift-toolkit ibm-roks-toolkit:${RELEASE_TAG} &> /dev/null; then
  echo "Tagging ibm-roks-toolkit image with ${RELEASE_TAG}"
  oc tag registry.ci.openshift.org/hypershift-toolkit/ibm-roks-${RELEASE_PREFIX}:ibm-roks-toolkit \
        ibm-roks-toolkit:${RELEASE_TAG} \
        -n hypershift-toolkit
else
  echo "ibm-roks-toolkit image tag ${RELEASE_TAG} already exists"
fi

if ! oc get istag -n hypershift-toolkit ibm-roks-metrics:${RELEASE_TAG} &> /dev/null; then
  echo "Tagging ibm-roks-metrics image with ${RELEASE_TAG}"
  oc tag registry.ci.openshift.org/hypershift-toolkit/ibm-roks-${RELEASE_PREFIX}:metrics \
      ibm-roks-metrics:${RELEASE_TAG} \
      -n hypershift-toolkit
else
  echo "ibm-roks-metrics image tag ${RELEASE_TAG} already exists"
fi
