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

if [[ "${RELEASE%-*}" != "${RELEASE%}" ]] ; then
  if [[ -f "${RELEASE}.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("${RELEASE}.yaml")
  fi
  if [[ -f "${RELEASE}-secrets.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("secrets://${RELEASE}-secrets.yaml")
  fi
fi

if [[ -f "${CONTEXT}/${RELEASE%-*}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${RELEASE%-*}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${RELEASE%-*}-secrets.yaml")
fi

if [[ "${CONTEXT}/${RELEASE%-*}" != "${CONTEXT}/${RELEASE}" ]] ; then
  if [[ -f "${CONTEXT}/${RELEASE}.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("${CONTEXT}/${RELEASE}.yaml")
  fi
  if [[ -f "${CONTEXT}/${RELEASE}-secrets.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("secrets://${CONTEXT}/${RELEASE}-secrets.yaml")
  fi
fi

if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("${CONTEXT}/${NAMESPACE}/${RELEASE%-*}.yaml")
fi
if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml" ]] ; then
  ARGS+=("--values")
  ARGS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE%-*}-secrets.yaml")
fi

if [[ "${CONTEXT}/${NAMESPACE}/${RELEASE%-*}" != "${CONTEXT}/${NAMESPACE}/${RELEASE}" ]] ; then
  if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("${CONTEXT}/${NAMESPACE}/${RELEASE}.yaml")
  fi
  if [[ -f "${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml" ]] ; then
    ARGS+=("--values")
    ARGS+=("secrets://${CONTEXT}/${NAMESPACE}/${RELEASE}-secrets.yaml")
  fi
fi

popd >/dev/null || exit

info() {
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo ""
  echo "release:       ${RELEASE}"
  echo "chart:         ${CHART}"
  echo ""
  echo "arguments:     ${ARGS[@]}"
  echo ""
  echo "cluster:       ${CONTEXT}"
  echo "namespace:     ${NAMESPACE}"
  echo ""
}

info
read -p "show diff  [y/N] " answer
case ${answer:0:1} in
  y | Y)
    helm diff upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}"
    ;;
  *)
    ;;
esac

info
read -p "test  [y/N] " answer
case ${answer:0:1} in
  y | Y)
    helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --dry-run
    ;;
  *)
    ;;
esac

info
read -p "install  [y/N] " answer
case ${answer:0:1} in
  y | Y)
    helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --timeout=30m
    ;;
  *)
    ;;
esac
