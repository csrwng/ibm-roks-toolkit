#!/bin/bash
set -euo pipefail

REPODIR="$(dirname "$0")/.."

if [[ ! -f "${REPODIR}/release" ]]; then
  echo "Release name file (release) does not exist. Nothing to do"
fi
if [[ ! -f "${REPODIR}/release-date" ]]; then
  echo "Release date file (release-date) does not exist. Nothing to do"
fi

RELEASE="$(cat "${REPODIR}/release")"
RELEASE_DATE="$(cat "${REPODIR}/release-date")"
RELEASE_TAG="v${RELEASE}-${RELEASE_DATE}"
RELEASE_BRANCH="release-${RELEASE}"

# if the branch doesn't exist, default to master
if ! git rev-parse --verify "${RELEASE_BRANCH}" &> /dev/null; then
  RELEASE_BRANCH="master"
fi

if git rev-list ${RELEASE_TAG}.. &>/dev/null; then
  echo "The release ${RELEASE_TAG} already exists. Nothing to do"
  exit
fi

echo "Creating release ${RELEASE_TAG}"

git tag "${RELEASE_TAG}"
GORELEASER_CURRENT_TAG="${RELEASE_TAG}" goreleaser release --skip-publish --config "${REPODIR}/hack/release-config.yaml"

GITHUB_TOKEN="${GITHUB_TOKEN:-}"
if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "GITHUB_TOKEN is not present, will skip publishing release"
  exit
fi

hub release create \
  -a "./dist/ibm-roks-toolkit_${RELEASE_TAG}_linux_x86_64.tar.gz" \
  -a "./dist/checksums.txt" \
  -m "${RELEASE_TAG} ${RELEASE_DATE}" \
  -t "${RELEASE_BRANCH}" \
  "${RELEASE_TAG}"
