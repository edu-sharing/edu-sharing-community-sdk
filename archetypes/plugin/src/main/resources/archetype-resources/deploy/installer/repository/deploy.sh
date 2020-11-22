#!/bin/bash
set -e
set -o pipefail

export CLI_CMD="$0"
export CLI_OPT1="$1"
export CLI_OPT2="$2"
export CLI_OPT3="$3"
export CLI_OPT4="$4"

if [ -z "${M2_HOME}" ]; then
	export MVN_EXEC="mvn"
else
	export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

ROOT_PATH="$(
	cd "$(dirname ".")"
	pwd -P
)"
export ROOT_PATH

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)" >/dev/null || exit

BUILD_PATH="$(
	cd "$(dirname ".")"
	pwd -P
)"
export BUILD_PATH

pushd "${BUILD_PATH}/../../../repository" >/dev/null || exit
PLUGIN_PATH=$(pwd)
export PLUGIN_PATH
popd >/dev/null || exit

build() {
	[[ -z "${CLI_OPT2}" ]] && {
		echo ""
		echo "Usage: ${CLI_CMD} ${CLI_OPT1} <repository-project>"
		exit
	}

	pushd "${ROOT_PATH}/${CLI_OPT2}" >/dev/null || exit
	COMMUNITY_PATH=$(pwd)
	export COMMUNITY_PATH
	popd >/dev/null || exit

	echo "Checking version ..."

	pushd "${BUILD_PATH}" >/dev/null || exit
	EXPECTED_VERSION=$($MVN_EXEC -q -ff -nsu -N help:evaluate -Dexpression=community.repository.version -DforceStdout)
	popd >/dev/null || exit

	pushd "${COMMUNITY_PATH}" >/dev/null || exit
	PROJECT_VERSION=$($MVN_EXEC -q -ff -nsu -N help:evaluate -Dexpression=project.version -DforceStdout)
	echo "- repository         [ ${PROJECT_VERSION} ]"
	popd >/dev/null || exit

	[[ "${EXPECTED_VERSION}" != "${PROJECT_VERSION}" ]] && {
		echo "Error: expected version [ ${EXPECTED_VERSION} ] is different."
		exit
	}

	echo "Building ..."

	echo "- repository"
	pushd "${COMMUNITY_PATH}" >/dev/null || exit
	$MVN_EXEC -q -ff -Dmaven.test.skip=true clean install || exit
	popd >/dev/null || exit

	echo "- plugin"
	pushd "${PLUGIN_PATH}" >/dev/null || exit
	$MVN_EXEC -q -ff -Dmaven.test.skip=true clean install || exit
	popd >/dev/null || exit

	echo "- installer"
	pushd "${BUILD_PATH}" >/dev/null || exit
	$MVN_EXEC -q -ff -Dmaven.test.skip=true clean install || exit
	popd >/dev/null || exit
}

case "${CLI_OPT1}" in
build)
	build
	;;
*)
	echo ""
	echo "Usage: ${CLI_CMD} [option]"
	echo ""
	echo "Option:"
	echo "  - build <repository-project>"
	echo ""
	;;
esac

popd >/dev/null || exit
