#!/bin/bash
set -e
set -o pipefail

pushd "${EDU_ROOT:-$HOME/.edusharing}" #>/dev/null || exit 1

[[ ! -d ./main ]] && {
	echo "please run: esgit.sh worktree add"
	exit 1
}

repos=(edu-sharing-community-parent)
repos+=(edu-sharing-community-bom)
repos+=(edu-sharing-community-repository)
repos+=(edu-sharing-community-plugin-elastic)
#repos+=(edu-sharing-community-plugin-mongo)
repos+=(edu-sharing-enterprise-repository-plugin-cluster)
repos+=(edu-sharing-enterprise-repository-plugin-remote)
repos+=(edu-sharing-enterprise-repository-plugin-transform)
repos+=(edu-sharing-community-services-rendering)
repos+=(edu-sharing-community-deploy)
repos+=(edu-sharing-community-sdk)

export OPTS="${MAVEN_CLI_OPTS:-"-ff -DskipTests"}"

install() {
	shift || exit 1
	path="link/$1"
	[[ -d "${path}" ]] && {
		for repo in "${repos[@]}"
    do
			pushd "${path}/${repo}.git" >/dev/null || exit 1
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
