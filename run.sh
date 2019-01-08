#!/bin/bash

set -euo pipefail

if [ -z "${PLUGIN_UPLOAD}" ]; then
  echo "Must specify locations to upload in \$PLUGIN_UPLOAD. Exiting!"
  exit 1
fi

if [ -z "${PLUGIN_BUCKET}" ]; then
  echo "Must provide S3 bucket name in \$PLUGIN_BUCKET. Exiting!"
  exit 1
fi

# Default to root bucket folder and strip leading slashes
PLUGIN_FOLDER=${PLUGIN_FOLDER:-""}
PLUGIN_FOLDER=${PLUGIN_FOLDER#/}

PLUGIN_VERBOSE=${PLUGIN_VERBOSE:-""}

VERBOSE=""
if [[ -n "${PLUGIN_VERBOSE}" && "${PLUGIN_VERBOSE}" == "true" ]]; then
  VERBOSE="-v"
fi

ARCHIVE_PATH="/${PLUGIN_FOLDER}/${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}/${DRONE_BUILD_NUMBER}"
PATHS_TO_TAR=${PLUGIN_UPLOAD//,/ }

echo "Starting at $(date)"

PATHS=""
echo "Compressing selected paths:"
for i in ${PATHS_TO_TAR}; do
  if test -e "${i}"; then
    PATHS+=" ${i}"
    echo "Adding ${i}"
  else
    echo "Cannot find ${i}. Skipping."
  fi
done
PATHS=${PATHS# }

if [[ $PATHS == "" ]]; then
  echo "No paths found for archive. Moving on..."
  exit 0
else
  tar cf - ${PATHS} | pigz ${VERBOSE} > archive.tgz
fi

echo "Compression complete, uploading to S3"

s3cmd ${VERBOSE} sync archive.tgz "s3://${PLUGIN_BUCKET}${ARCHIVE_PATH}/archive.tgz"

echo "Upload completed! Download this build's log archive from:"
echo "https://${PLUGIN_BUCKET}.s3.amazonaws.com${ARCHIVE_PATH}/archive.tgz"

echo "Finished! Exiting at $(date)" && exit 0
