#!/bin/bash
set -eux -o pipefail

if aptly mirror create -ignore-signatures erweka-mirror https://minio.dev.erweka.com/repo.erweka.info bionic main ;
then
  aptly mirror update -ignore-signatures erweka-mirror
  aptly snapshot create erweka-snapshot from mirror erweka-mirror

  aptly repo create -distribution=bionic -component=main erweka-"${{ inputs.repo-name }}"
  aptly repo add erweka-"${{ inputs.repo-name }}" deb-package
  aptly snapshot create erweka-snapshot-"${{ inputs.repo-name }}" from repo erweka-"${{ inputs.repo-name }}"

  aptly snapshot merge -no-remove erweka-snapshot-"${{ inputs.repo-name }}"-merged-"${{ inputs.build-version }}" erweka-snapshot erweka-snapshot-"${{ inputs.repo-name }}"
  aptly snapshot show -with-packages erweka-snapshot-"${{ inputs.repo-name }}"-merged-"${{ inputs.build-version }}"
  aptly publish snapshot -force-overwrite -batch erweka-snapshot-"${{ inputs.repo-name }}"-merged-"${{ inputs.build-version }}" s3:erweka.repo:
else
  aptly repo create -distribution=bionic -component=main erweka-deb
  aptly repo add erweka-deb deb-package
  aptly publish repo -batch erweka-deb s3:erweka.repo:
fi
