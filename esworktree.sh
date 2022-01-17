#!/bin/bash
set -e
set -o pipefail

root=${EDU_ROOT:-$HOME/.edusharing}
mkdir -p "${root}"

echo "################################################################################"
echo "root: ${root}"
echo "################################################################################"

pushd "${root}" >/dev/null || exit 1

repos=(parent)
repos+=(bom)
repos+=(repository)
repos+=(repository-plugin-elastic)
#repos+=(repository-plugin-mongo)
repos+=(repository-plugin-cluster)
repos+=(repository-plugin-remote)
repos+=(repository-plugin-transform)
repos+=(services-rendering)
repos+=(deploy)
repos+=(sdk)

mkdir -p main
pushd main >/dev/null || exit 1
[[ ! -d parent ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
[[ ! -d bom ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
[[ ! -d repository ]] && git clone --no-checkout --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
[[ ! -d repository-plugin-cluster ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
[[ ! -d repository-plugin-elastic ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
#[[ ! -d repository-plugin-mongo ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
[[ ! -d repository-plugin-remote ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
[[ ! -d repository-plugin-transform ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
[[ ! -d services-rendering ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
[[ ! -d deploy ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
[[ ! -d sdk ]] && git clone --no-checkout https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
popd >/dev/null

add() {
	shift || exit 1
	local="$1"
	remote="$2"
	path="link/$local"
	[[ -d "${path}" ]] && exit 1
	for repo in main/*/; do
		pushd "$repo" >/dev/null || exit 1
		echo "################################################################################"
		echo "$repo"
		echo "################################################################################"

		git fetch origin "$remote"

		worktreePath="../../${path}/$(basename "$repo")"
		[[ ! -d "$worktreePath" ]] && {

			git worktree add -b "$local" --track "${worktreePath}" "origin/$remote"

			pushd "../../${path}/$(basename "$repo")" >/dev/null
			[[ -f .gitmodules ]] && {
				git submodule init
				git submodule update --recursive
			}
			popd >/dev/null
		}
		popd >/dev/null
	done

	echo ""
	echo "worktree added -> $(cd . && pwd)/${path}"
	echo ""
}

remove() {
	shift || exit 1
	local="$1"
	read -p "Are you sure you want to continue? [y/N] " answer
	case ${answer:0:1} in
	y | Y)
		path="link/$local"
		[[ ! -d "${path}" ]] && exit 1
		for repo in main/*/; do
			link="../../${path}/$(basename "$repo")"
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			git worktree remove --force "${link}"
			git branch -d "$local"
			popd >/dev/null
			rm -rf "${link}"
		done
		rm -rf "${path}"

		echo ""
		echo "worktree removed -> $(cd . && pwd)/${path}"
		echo ""
		;;
	*)
		echo Canceled.
		;;
	esac
}

list() {
	[[ ! -d "main" ]] && exit 1
	for repo in main/*/; do
		pushd "$repo" >/dev/null || exit 1
		echo "################################################################################"
		echo "$repo"
		echo "################################################################################"
		git worktree list
		popd >/dev/null
	done
}

prune() {
	[[ ! -d "main" ]] && exit 1
	for repo in main/*/; do
		pushd "$repo" >/dev/null || exit 1
		echo "################################################################################"
		echo "$repo"
		echo "################################################################################"
		git worktree prune
		popd >/dev/null
	done
}

build() {
	shift || exit 1
	local="$1"
	path="link/$local"
	[[ ! -d "${path}" ]] && exit 1

	read -p "repository.cluster      [y/N] " answer
	case ${answer:0:1} in
	y | Y)
	  export REPOSITORY_CLUSTER_ENABLED=true
		;;
	*)
	  export REPOSITORY_CLUSTER_ENABLED=false
		;;
	esac

	read -p "repository.elastic      [y/N] " answer
	case ${answer:0:1} in
	y | Y)
	  export REPOSITORY_ELASTIC_ENABLED=true
		;;
	*)
	  export REPOSITORY_ELASTIC_ENABLED=false
		;;
	esac

	read -p "repository.mongo        [y/N] " answer
	case ${answer:0:1} in
	y | Y)
	  export REPOSITORY_MONGO_ENABLED=true
		;;
	*)
	  export REPOSITORY_MONGO_ENABLED=false
		;;
	esac

	read -p "repository.remote       [y/N] " answer
	case ${answer:0:1} in
	y | Y)
	  export REPOSITORY_REMOTE_ENABLED=true
		;;
	*)
	  export REPOSITORY_REMOTE_ENABLED=false
		;;
	esac

	read -p "repository.transform    [y/N] " answer
	case ${answer:0:1} in
	y | Y)
	  export REPOSITORY_TRANSFORM_ENABLED=true
		;;
	*)
	  export REPOSITORY_TRANSFORM_ENABLED=false
		;;
	esac

	for repo in "${repos[@]}"
	do
		pushd "${path}/${repo}" >/dev/null || exit 1
		echo "################################################################################"
		echo "$repo"
		echo "################################################################################"
		mvn $OPTS clean install
		popd >/dev/null
	done
}

case "$1" in
add)
	add "$@"
#	build "$@"
	;;
remove)
	remove "$@"
	;;
list)
	list
	;;
prune)
	prune
	;;
build)
	build "$@"
	;;
*)
	{
		echo "options:"
		echo "  add    <local-branch> <remote-branch>"
		echo "  remove <local-branch>"
		echo "  list"
		echo "  prune"
		echo ""
		echo "  build <local-branch>"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
