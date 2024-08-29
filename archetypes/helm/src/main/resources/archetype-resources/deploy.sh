#!/bin/bash
set -e
set -o pipefail

if [[ -z $1 ]] ; then
  echo ""
  echo "deploy.sh [options] <release> <chart> [<version|path>]"
  echo "  options:"
  echo "     -s                       # skip checks and deploy directly"
  echo "     -d                       # run diff"
  echo "     -t                       # run try run"
  echo "     -e                       # run execute deployment"
  echo ""
  exit 0
fi

SKIP=false
WIZARD=true
DIFF=false
TRY_RUN=false
DEPLOY=false
while getopts sdte opt; do
    case $opt in
        s)
          SKIP=true
          ;;
        d)
          WIZARD=false
          DIFF=true
          ;;
        t)
          WIZARD=false
          TRY_RUN=true
          ;;
        e)
          WIZARD=false
          DEPLOY=true
          ;;
        *)
          ;;
    esac
done

shift $(( "$OPTIND" - 1))

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

diff() {
  echo "Request diff from last revision, please wait ..."
  echo ""
  # temporarily disable the script from exiting on a non-zero status code
  set +e
  helm diff upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}"
  set -e
}

tryRun(){
  echo "Dry-run, please wait ..."
  echo ""
  helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --dry-run --debug
}

execute(){
  echo "Execute, please wait ..."
  echo ""
  helm upgrade --install "${RELEASE}" "${CHART}" "${ARGS[@]}" --timeout=30m
}


runAsWizard() {
  if [ "$SKIP" = false ] ; then
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
        helm history ${RELEASE} 2>/dev/null || echo "skipped ..."
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
    echo "options:       ${ARGS[*]}"
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
        diff
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
        tryRun
        ;;
      *)
        echo "skipped ..."
        ;;
    esac

  fi
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo ""
  read -p "---> perform deployment [y/N] " answer
  echo ""
  echo "--------------------------------------------------------------------------------"
  echo ""

  case ${answer:0:1} in
    y | Y)
      execute
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
}


if [[ $WIZARD == "true" ]] ; then
  runAsWizard
else
  [[ $DIFF == "true" ]] && {
    diff
  }
  [[ $TRY_RUN == "true" ]] && {
    tryRun
  }

  [[ $DEPLOY == "true" ]] && {
    execute
  }
fi
