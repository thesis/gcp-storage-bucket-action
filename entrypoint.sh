#!/bin/bash

if [[ -n $TEST ]]; then
  inputs="$INPUT_SERVICE_KEY $INPUT_PROJECT $INPUT_BUCKET_NAME $INPUT_BUILD_FOLDER $INPUT_HOME_PAGE_PATH $INPUT_ERROR_PAGE_PATH"

  if [[ $inputs = $TEST ]]; then
    echo "Inputs equal test expectations."
    exit 0
  else
    printf "Got unexpected inputs:\n$inputs\nvs\n$TEST"
    exit 1
  fi
fi

# Decode Base64-key to json file
echo "$INPUT_SERVICE_KEY" | base64 --decode > "$HOME"/service_key.json

gcloud auth activate-service-account --key-file="$HOME"/service_key.json --project "$INPUT_PROJECT"

gsutil rsync -R "$INPUT_BUILD_FOLDER" gs://"$INPUT_BUCKET_NAME"
gsutil web set -m "$INPUT_HOME_PAGE_PATH" -e "$INPUT_ERROR_PAGE_PATH" gs://"$INPUT_BUCKET_NAME"
