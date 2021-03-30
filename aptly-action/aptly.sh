#!/bin/bash
set -eux -o pipefail

aptly mirror drop -force erweka-mirror || true
aptly snapshot drop erweka-snapshot || true
aptly repo drop erweka-"${REPO_NAME}" || true
aptly snapshot drop erweka-snapshot-"${REPO_NAME}" || true

if aptly mirror create -ignore-signatures erweka-mirror "${TARGET_URL}"/"${TARGET_BUCKET}" bionic main ;
then
  aptly mirror update -ignore-signatures erweka-mirror
  aptly snapshot create erweka-snapshot from mirror erweka-mirror
  aptly snapshot show -with-packages erweka-snapshot

  aptly repo create -distribution=bionic -component=main erweka-"${REPO_NAME}"
  aptly repo add erweka-"${REPO_NAME}" deb-package
  aptly snapshot create erweka-snapshot-"${REPO_NAME}" from repo erweka-"${REPO_NAME}"

  aptly snapshot merge -no-remove erweka-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}" erweka-snapshot erweka-snapshot-"${REPO_NAME}"
  aptly snapshot show -with-packages erweka-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}"
  aptly publish snapshot -force-overwrite -batch erweka-snapshot-"${REPO_NAME}"-merged-"${BUILD_VERSION}" s3:erweka.repo:
else
  aptly repo create -distribution=bionic -component=main erweka-deb
  aptly repo add erweka-deb deb-package
  aptly publish repo -batch erweka-deb s3:erweka.repo:
fi
