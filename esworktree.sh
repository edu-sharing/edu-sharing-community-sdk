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
repos+=(deploy/docker)
repos+=(sdk)

[[ ! -d main ]] && {
	mkdir -p main
	pushd main >/dev/null || exit 1
	branch="maven/develop"
	[[ ! -d parent ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
	[[ ! -d bom ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
	[[ ! -d repository ]] && git clone -bare -b "$branch" --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
	[[ ! -d repository-plugin-cluster ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
	[[ ! -d repository-plugin-elastic ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
	#[[ ! -d repository-plugin-mongo ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
	[[ ! -d repository-plugin-remote ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
	[[ ! -d repository-plugin-transform ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
	[[ ! -d services-rendering ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
	[[ ! -d deploy ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
	[[ ! -d sdk ]] && git clone -bare -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
	popd >/dev/null
}

add() {
	shift || exit 1
	path="link/$1"
	[[ ! -d "${path}" ]] && {
		for repo in main/*/; do
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			clonePath="../../${path}/$(basename "$repo")"
			[[ ! -d "$clonePath" ]] && {
				git worktree add "$clonePath" -b "$1"

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
}

remove() {
	shift || exit 1
	path="link/$1"
	[[ -d "${path}" ]] && {
		for repo in main/*/; do
			link="../../${path}/$(basename "$repo")"
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			git worktree remove "${link}"
			popd >/dev/null
			rm -rf "${link}"
		done
		rm -rf "${path}"

		echo ""
		echo "worktree removed -> $(cd . && pwd)/${path}"
		echo ""
	}
}

prune() {
	[[ -d "main" ]] && {
		for repo in main/*/; do
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			git worktree prune
			echo ""
			echo "worktrees pruned."
			echo ""
			popd >/dev/null
		done
	}
}

build() {
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
    	popd >/dev/null
    done
	}
}

case "$1" in
add)
	add "$@"
	;;
remove)
	remove "$@"
	;;
prune)
	prune "$@"
	;;
build)
	build "$@"
	;;
*)
	{
		echo "options:"
		echo "  add <worktree>"
		echo "  remove <worktree>"
		echo "  prune"
		echo ""
		echo "  build <worktree>"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
