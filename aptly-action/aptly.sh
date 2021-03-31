#!/bin/bash
set -eux -o pipefail

aptly version
aptly config show
aptly mirror drop -force aptly-mirror || true
aptly snapshot drop -force aptly-snapshot || true
aptly repo drop -force aptly-"${REPO_NAME}" || true
aptly snapshot drop -force aptly-snapshot-"${REPO_NAME}" || true
aptly snapshot drop -force aptly-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}" || true

if aptly mirror create -ignore-signatures aptly-mirror https://"${TARGET_URL}"/"${TARGET_BUCKET}" bionic main ;
then
  aptly mirror update -ignore-signatures aptly-mirror
  aptly snapshot create aptly-snapshot from mirror aptly-mirror
  aptly snapshot show -with-packages aptly-snapshot

  aptly repo create -distribution=bionic -component=main aptly-"${REPO_NAME}"
  aptly repo add aptly-"${REPO_NAME}" "${DEB_FOLDER}"
  aptly snapshot create aptly-snapshot-"${REPO_NAME}" from repo aptly-"${REPO_NAME}"

  aptly snapshot merge -no-remove aptly-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}" aptly-snapshot aptly-snapshot-"${REPO_NAME}"
  aptly snapshot show -with-packages aptly-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}"
  aptly publish snapshot -force-overwrite -batch aptly-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}" s3:"${APTLY_TARGET}":
else
  aptly repo create -distribution=bionic -component=main aptly-deb
  aptly repo add aptly-deb "${DEB_FOLDER}"
  aptly publish repo -batch aptly-deb s3:"${APTLY_TARGET}":
fi

