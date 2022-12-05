#!/bin/bash
set -e
set -o pipefail

RELEASE=${1?"release required"}
CHART=${2?"chart required"}
VERSION=${3:-""}

CONTEXT="$(kubectl config current-context)"
NAMESPACE="$(kubectl config view --minify --output 'jsonpath={..namespace}')"

SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

ARGS=()

if [[ ! -f ${CHART} ]] ; then

  ARGS+=("--version")
  ARGS+=("${VERSION:->=0.0.0-0}")

fi

pushd "${SOURCE_PATH}" >/dev/null || exit

if [[ -f "${RELEASE%-*}.yaml" ]]; then
  ARGS+=("--values")
  ARGS+=("${RELEASE%-*}.yaml")
fi
if [[ -f "${RELEASE%-*}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${RELEASE}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${RELEASE}.yaml")
fi
if [[ -f "${RELEASE}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${RELEASE}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${RELEASE%-*}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${RELEASE%-*}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${RELEASE}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${RELEASE}.yaml")
fi
if [[ -f "${CONTEXT}/${RELEASE}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${RELEASE}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml")
fi

if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml")
fi
if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml")
fi

if [[ -n "${HELM_TIMEOUT}" ]] ; then
  ARGS+=("--timeout")
  ARGS+=("${HELM_TIMEOUT}")
fi

if [[ -n "${HELM_DEBUG}" ]] ; then
  ARGS+=("--dry-run")
  ARGS+=("--debug")
fi

popd >/dev/null || exit

set -x
helm ${HELM_PLUGIN} upgrade --install "${RELEASE}" \
  "${CHART}" \
  "${ARGS[@]}"
set +x
