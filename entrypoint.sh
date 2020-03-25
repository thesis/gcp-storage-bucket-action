#!/bin/bash
# Exit on error.
set -ex

read -r INPUT_SERVICE_KEY INPUT_PROJECT INPUT_BUCKET_NAME INPUT_BUCKET_PATH \
  INPUT_BUILD_FOLDER INPUT_SET_WEBSITE INPUT_HOME_PAGE_PATH \
  INPUT_ERROR_PAGE_PATH <<<$*

# TEST env variable indicates we should be in testing mode (below).
if [[ -z $TEST ]]; then
  if [[ $INPUT_BUCKET_PATH == "." ]]; then
    INPUT_BUCKET_PATH=""
  fi

  # Decode Base64-key to json file
  echo "$INPUT_SERVICE_KEY" | base64 -d > "$HOME"/service_key.json

  gcloud auth activate-service-account --key-file="$HOME"/service_key.json --project "$INPUT_PROJECT"

  gsutil -m rsync -R "$INPUT_BUILD_FOLDER" gs://"$INPUT_BUCKET_NAME"/"$INPUT_BUCKET_PATH"

  if [[ $INPUT_SET_WEBSITE = "true" ]]; then
    gsutil web set -m "$INPUT_HOME_PAGE_PATH" -e "$INPUT_ERROR_PAGE_PATH" gs://"$INPUT_BUCKET_NAME"
  fi
else
  inputs="sk: $INPUT_SERVICE_KEY p: $INPUT_PROJECT bn: $INPUT_BUCKET_NAME bp: $INPUT_BUCKET_PATH bf: $INPUT_BUILD_FOLDER sw: $INPUT_SET_WEBSITE hpp: $INPUT_HOME_PAGE_PATH epp: $INPUT_ERROR_PAGE_PATH"

  if [[ $inputs = $TEST ]]; then
    echo "Inputs equal test expectations."
    exit 0
  else
    printf "Got unexpected inputs:\n$inputs\nvs\n$TEST"
    exit 1
  fi
fi

