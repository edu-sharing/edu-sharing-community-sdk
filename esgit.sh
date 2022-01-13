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
[[ ! -d edu-sharing-community-bom.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git --bare
[[ ! -d edu-sharing-community-deploy.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git --bare
[[ ! -d edu-sharing-community-parent.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git --bare
[[ ! -d edu-sharing-community-sdk.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git --bare
[[ ! -d edu-sharing-community-repository.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git --recurse-submodules --bare
[[ ! -d edu-sharing-community-repository-plugin-elastic.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git --bare
#[[ ! -d edu-sharing-community-repository-plugin-mongo.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git --bare
[[ ! -d edu-sharing-community-services-rendering.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git --bare
[[ ! -d edu-sharing-enterprise-repository-plugin-cluster.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git --bare
[[ ! -d edu-sharing-enterprise-repository-plugin-remote.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git --bare
[[ ! -d edu-sharing-enterprise-repository-plugin-transform.git ]] && git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git --bare
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
			git branch -d "$1"
			popd >/dev/null
			rm -rf "${link}"
		done
		rm -rf "${path}"
		echo ""
		echo "worktree removed -> $(cd . && pwd) "
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
	*)
		{
			echo "options:"
			echo "  add <worktree>"
			echo "  remove <worktree>"
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
