#!/bin/bash
set -e
set -o pipefail

root=${EDU_ROOT:-$HOME/.edusharing}
mkdir -p "${root}"

echo "################################################################################"
echo "root: ${root}"
echo "################################################################################"

pushd "${root}" >/dev/null || exit 1
#init for worktree
#mkdir -p main
#pushd main >/dev/null || exit 1
#branch="maven/develop"
#[[ ! -d bom ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
#[[ ! -d deploy ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
#[[ ! -d parent ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
#[[ ! -d sdk ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
#[[ ! -d repository ]] && git clone -b "$branch" --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
#[[ ! -d repository-plugin-elastic ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
##[[ ! -d repository-plugin-mongo ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
#[[ ! -d services-rendering ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
#[[ ! -d repository-plugin-cluster ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
#[[ ! -d repository-plugin-remote ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
#[[ ! -d repository-plugin-transform ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
#popd >/dev/null

worktree_add() {
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

clone() {
	shift || exit 1
	path="main/$1"

	mkdir -p "$path"
	pushd "$path" >/dev/null || exit 1
	branch="maven/develop"
	[[ ! -d bom ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
	[[ ! -d deploy ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
	[[ ! -d parent ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
	[[ ! -d sdk ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
	[[ ! -d repository ]] && git clone -b "$branch" --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
	[[ ! -d repository-plugin-elastic ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
	#[[ ! -d repository-plugin-mongo ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
	[[ ! -d services-rendering ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
	[[ ! -d repository-plugin-cluster ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
	[[ ! -d repository-plugin-remote ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
	[[ ! -d repository-plugin-transform ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
	popd >/dev/null

	for repo in "$path"/*/; do
		pushd "$repo" >/dev/null || exit 1

		currentBranch="$(git rev-parse --abbrev-ref HEAD)"
		[[ "$currentBranch" != "$1" ]] && {
			git checkout -b "$1"
			[[ -f .gitmodules ]] && {
				git submodule init
				git submodule update --recursive
			}
		}
		popd >/dev/null
	done
}

remove() {
	shift || exit 1
	path="main/$1"
	[[ -d "${path}" ]] && {
		rm -rf "${path}"
	}
}

case "$1" in
#worktree)
#	worktree "$@"
#	;;
clone)
	clone "$@"
	;;
*)
	{
		echo "options:"
		echo "  clone <branch>"
		#		echo "  worktree"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
