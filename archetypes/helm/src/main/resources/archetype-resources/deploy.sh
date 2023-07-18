#!/bin/bash
set -e
set -o pipefail

if [[ -z $1 ]] ; then
  echo ""
  echo "deploy.sh <release> <chart> [<version|path>]"
  echo ""
  exit 0
fi

RELEASE=${1?"release required"}
CHART=${2?"chart required"}
VERSION=${3:-"":->=0.0.0-0}

CONTEXT="$(kubectl config current-context)"
NAMESPACE="$(kubectl config view --minify --output 'jsonpath={..namespace}')"

SOURCE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

ARGS=()

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

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
echo "cluster:       ${CONTEXT}"
echo "namespace:     ${NAMESPACE}"
echo ""
echo "--------------------------------------------------------------------------------"
echo ""
read -p "---> kubectl context ok [y/N] " answer
echo ""
echo "--------------------------------------------------------------------------------"
echo ""
case ${answer:0:1} in
  y | Y)
    echo "Request existing releases, please wait ..."
    echo ""
    helm repo update >/dev/null
    helm ls -a
    ;;
  *)
    exit 0
    ;;
esac

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
echo "release:       ${RELEASE}"
echo ""
echo "--------------------------------------------------------------------------------"
echo ""
read -p "---> helm release ok [y/N] " answer
echo ""
echo "--------------------------------------------------------------------------------"
echo ""

case ${answer:0:1} in
  y | Y)
    echo "Request existing revisions, please wait ..."
    echo ""
    helm history ${RELEASE} 2>/dev/null
    ;;
  *)
    exit 0
    ;;
esac

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
echo "chart:         ${CHART}"
echo "version:       ${VERSION}"
echo "options:       ${ARGS[@]}"
echo ""
echo "--------------------------------------------------------------------------------"
echo ""
read -p "---> helm parameter ok [y/N] " answer
echo ""
echo "--------------------------------------------------------------------------------"
echo ""

if [[ ! -f ${CHART} ]] ; then

  ARGS+=("--version")
  ARGS+=("${VERSION}")

fi

case ${answer:0:1} in
  y | Y)
    echo "Request diff from last revision, please wait ..."
    echo ""
    helm diff upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}"
    ;;
  *)
    exit 0
    ;;
esac

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
read -p "---> perform test [y/N] " answer
echo ""
echo "--------------------------------------------------------------------------------"
echo ""

case ${answer:0:1} in
  y | Y)
    echo "Dry-run, please wait ..."
    echo ""
    helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --dry-run --debug
    ;;
  *)
    echo "skipped ..."
    ;;
esac

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
read -p "---> perform deployment [y/N] " answer
echo ""
echo "--------------------------------------------------------------------------------"
echo ""

case ${answer:0:1} in
  y | Y)
    echo "Run, please wait ..."
    echo ""
    helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --timeout=30m
    ;;
  *)
    echo "skipped ..."
    ;;
esac

echo ""
echo "--------------------------------------------------------------------------------"
echo ""
echo "done"
echo ""
