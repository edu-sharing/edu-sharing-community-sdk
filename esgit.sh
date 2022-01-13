#!/bin/bash
set -e
set -o pipefail

pushd "${EDU_ROOT:-$HOME/.edusharing}" >/dev/null || exit 1

[[ ! -d ./main ]] && {
	mkdir -p main
	pushd main >/dev/null || exit 1
	git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git --recurse-submodules -bare
	git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git -bare
#	git clone https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git -bare
	git clone https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git -bare
	popd >/dev/null
}

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
		echo "  worktree"
	} >&2
	exit 1
	;;
esac

popd >/dev/null
