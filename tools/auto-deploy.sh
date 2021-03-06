#!/bin/bash
# fail on errors
set -e

CLOUDSDK_URL=https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
SDK_DIR=google-cloud-sdk

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_PYTHON_SITEPACKAGES=1

if [ ! -d $SDK_DIR ]; then
  mkdir -p $SDK_DIR
  curl -o /tmp/gcloud.tar.gz $CLOUDSDK_URL
  tar xzf /tmp/gcloud.tar.gz --strip 1 -C $SDK_DIR
  $SDK_DIR/install.sh
fi

openssl aes-256-cbc -d -k $SERVICE_SECRET \
        -in tools/web-central-44673aab0806.json.enc \
        -out tools/web-central-44673aab0806.json


$SDK_DIR/bin/gcloud config set project web-central
$SDK_DIR/bin/gcloud components update app -q
$SDK_DIR/bin/gcloud auth activate-service-account $SERVICE_ACCOUNT \
        --key-file tools/web-central-44673aab0806.json \
        --quiet
$SDK_DIR/bin/gcloud config set project web-central
$SDK_DIR/bin/gcloud config set app/promote_by_default false
$SDK_DIR/bin/gcloud config set app/use_appengine_api true
$SDK_DIR/bin/gcloud preview app modules cancel-deployment default --version $CI_BRANCH
$SDK_DIR/bin/gcloud preview app deploy --version $CI_BRANCH --bucket gs://${CI_BRANCH}-webcentral-appspot-com  ./build/app.yaml

