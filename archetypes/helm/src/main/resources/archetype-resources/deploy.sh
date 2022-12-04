#!/bin/bash
set -e
set -o pipefail

RELEASE=${1}
CHART=${2}
VERSION=${3:-""}
USERNAME=${4:-""}
PASSWORD=${5:-""}

CONTEXT="$(kubectl config current-context)"
NAMESPACE="$(kubectl config view --minify --output 'jsonpath={..namespace}')"

SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

OPTIONS=()

pushd "${SOURCE_PATH}" >/dev/null || exit

if [[ -f "${RELEASE%-*}.yaml" ]]; then
  OPTIONS+=("--values")
  OPTIONS+=("${RELEASE%-*}.yaml")
fi
if [[ -f "${RELEASE%-*}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${RELEASE}.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("${RELEASE}.yaml")
fi
if [[ -f "${RELEASE}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${RELEASE}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${RELEASE%-*}.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("${CONTEXT}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${RELEASE%-*}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${CONTEXT}/${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${RELEASE}.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("${CONTEXT}/${RELEASE}.yaml")
fi
if [[ -f "${CONTEXT}/${RELEASE}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${CONTEXT}/${RELEASE}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml")
fi
if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml" ]] ; then
  OPTIONS+=("--values")
  OPTIONS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml")
fi

[[ -n $USERNAME && -n $PASSWORD ]] && {
	OPTIONS+=("--set")
	OPTIONS+=("global.image.pullSecrets[0].name=registry")
	OPTIONS+=("--set")
	OPTIONS+=("image.pullSecrets[0].name=registry")
	OPTIONS+=("--set")
	OPTIONS+=("image.pullSecrets[0].server=${HELM_REGISTRY:-docker.edu-sharing.com}")
	OPTIONS+=("--set")
	OPTIONS+=("image.pullSecrets[0].username=${USERNAME}")
	OPTIONS+=("--set")
	OPTIONS+=("image.pullSecrets[0].password=${PASSWORD}")
}

file="../deploy/docker/helm/bundle/target/helm/repo/${CHART}-${VERSION}.tgz"

if [[ -f $file ]]; then

	set -x
	helm $HELM_PLUGIN upgrade --install "${RELEASE}" \
	  "${file}" \
    "${OPTIONS[@]}" \
    $HELM_OPTS
	set +x

else

	CREDENTIALS=()
	[[ -n $HELM_USER || -n $USERNAME ]] && {
		CREDENTIALS+=("--username")
		CREDENTIALS+=("${HELM_USER:-$USERNAME}")
	}
	[[ -n $HELM_PASS || -n $PASSWORD ]] && {
		CREDENTIALS+=("--password")
		CREDENTIALS+=("${HELM_PASS:-$PASSWORD}")
	}

	set -x
	helm $HELM_PLUGIN upgrade --install "${RELEASE}" \
		"${CHART}" --version "${VERSION}" \
		--repo "${HELM_REPO:-https://artifacts.edu-sharing.com/repository/helm/}" \
		"${CREDENTIALS[@]}" \
		"${OPTIONS[@]}" \
		$HELM_OPTS
	set +x

fi

popd >/dev/null || exit
