#!/bin/bash
set -e
set -o pipefail

pushd "${EDU_ROOT:-$HOME/.edusharing}" #>/dev/null || exit 1

[[ ! -d ./main ]] && {
	echo "please run: esgit.sh worktree add"
	exit 1
}

repos=(parent)
repos+=(bom)
repos+=(repository)
repos+=(repository-plugin-elastic)
#repos+=(repository-plugin-mongo)
repos+=(repository-plugin-cluster)
repos+=(repository-plugin-remote)
repos+=(repository-plugin-transform)
repos+=(services-rendering)
repos+=(deploy/docker)
repos+=(sdk)

export OPTS="${MAVEN_CLI_OPTS:-"-ff -DskipTests"}"

install() {
	shift || exit 1
	path="link/$1"
	[[ -d "${path}" ]] && {
		for repo in "${repos[@]}"
    do
			pushd "${path}/${repo}" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
    	mvn $OPTS install
    	#mvn install
    	popd >/dev/null
    done
	}
}

case "$1" in
install)
	install "$@"
	;;
*)
	{
		echo "  install"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
