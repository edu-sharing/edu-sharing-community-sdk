#!/bin/bash
set -e
set -o pipefail

root=${EDU_ROOT:-$HOME/.edusharing}
mkdir -p "${root}"

echo "################################################################################"
echo "root: ${root}"
echo "################################################################################"

pushd "${root}" >/dev/null || exit 1

mkdir -p main
pushd main >/dev/null || exit 1
[[ ! -d bom ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git --bare -b maven/develop bom
[[ ! -d deploy ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git --bare -b maven/develop deploy
[[ ! -d parent ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git --bare -b maven/develop parent
[[ ! -d sdk ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git --bare -b maven/develop sdk
[[ ! -d repository ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git --recurse-submodules --bare -b maven/develop repository
[[ ! -d repository-plugin-elastic ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git --bare -b maven/develop repository-plugin-elastic
#[[ ! -d repository-plugin-mongo ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git --bare -b maven/develop repository-plugin-mongo
[[ ! -d services-rendering ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git --bare -b maven/develop services-rendering
[[ ! -d repository-plugin-cluster ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git --bare -b maven/develop repository-plugin-cluster
[[ ! -d repository-plugin-remote ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git --bare -b maven/develop repository-plugin-remote
[[ ! -d repository-plugin-transform ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git --bare -b maven/develop repository-plugin-transform
popd >/dev/null

worktree_add() {
	shift || exit 1
	path="link/$1"
	[[ ! -d "${path}" ]] && {
		for repo in main/*/; do
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			git worktree add "../../${path}/$(basename "$repo")" -b "$1"

			pushd "../../${path}/$(basename "$repo")" >/dev/null
			[[ -f .gitmodules ]] && {
				git submodule init
				git submodule update --recursive
			}
			popd >/dev/null

			popd >/dev/null
		done
		echo ""
		echo "worktree added -> $(cd . && pwd) "
		echo ""
	}
}

worktree_remove() {
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
		echo "worktree removed -> $(cd . && pwd) "
		echo ""
	}
}

worktree_prune() {
	shift || exit 1
	path="link/$1"
	[[ -d "${path}" ]] && {
		for repo in main/*/; do
			link="../../${path}/$(basename "$repo")"
			pushd "$repo" >/dev/null || exit 1
			echo "################################################################################"
			echo "$repo"
			echo "################################################################################"
			git worktree prune
			popd >/dev/null
			rm -rf "${link}"
		done
		rm -rf "${path}"
		echo ""
		echo "worktree pruned -> $(cd . && pwd) "
		echo ""
	}
}

git_remove_branches() {
	shift || exit 1
	for repo in main/*/; do
		pushd "$repo" >/dev/null || exit 1
		echo "################################################################################"
		echo "$repo"
		echo "################################################################################"
		git branch -d "$(basename "$repo")"
		popd >/dev/null
	done
	echo ""
	echo "git branch removed -> $(cd . && pwd) "
	echo ""
}

worktree() {
	shift || exit 1
	case "$1" in
	add)
		worktree_add "$@"
		;;
	remove)
		worktree_remove "$@"
		;;
	prune)
		worktree_prune "$@"
		;;
	*)
		{
			echo "options:"
			echo "  add <worktree>"
			echo "  remove <worktree>"
			echo "  prune <worktree>"
		} >&2
		exit 1
		;;
	esac
}

case "$1" in
worktree)
	worktree "$@"
	;;
*)
	{
		echo "options:"
		echo "  worktree"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
