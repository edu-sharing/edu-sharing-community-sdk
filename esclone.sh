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

create() {
	shift || exit 1
	path="clone/$1"

	mkdir -p "$path"
	pushd "$path" >/dev/null || exit 1
	branch="$2"
	[[ ! -d parent ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
	[[ ! -d bom ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
	[[ ! -d repository ]] && git clone -b "$branch" --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
	[[ ! -d repository-plugin-cluster ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
	[[ ! -d repository-plugin-elastic ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
	#[[ ! -d repository-plugin-mongo ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
	[[ ! -d repository-plugin-remote ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
	[[ ! -d repository-plugin-transform ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
	[[ ! -d services-rendering ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
	[[ ! -d deploy ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
	[[ ! -d sdk ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
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

add() {
	shift || exit 1
	path="clone/$1"

	mkdir -p "$path"
	pushd "$path" >/dev/null || exit 1
	branch="$1"
	[[ ! -d parent ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-parent.git parent
	[[ ! -d bom ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-bom.git bom
	[[ ! -d repository ]] && git clone -b "$branch" --recurse-submodules https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository.git repository
	[[ ! -d repository-plugin-cluster ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-cluster.git repository-plugin-cluster
	[[ ! -d repository-plugin-elastic ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-elastic.git repository-plugin-elastic
	#[[ ! -d repository-plugin-mongo ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/repository/edu-sharing-community-repository-plugin-mongo.git repository-plugin-mongo
	[[ ! -d repository-plugin-remote ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-remote.git repository-plugin-remote
	[[ ! -d repository-plugin-transform ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/enterprise/repository/edu-sharing-enterprise-repository-plugin-transform.git repository-plugin-transform
	[[ ! -d services-rendering ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/services/edu-sharing-community-services-rendering.git services-rendering
	[[ ! -d deploy ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-deploy.git deploy
	[[ ! -d sdk ]] && git clone -b "$branch" https://scm.edu-sharing.com/edu-sharing/community/edu-sharing-community-sdk.git sdk
	popd >/dev/null

	for repo in "$path"/*/; do
		pushd "$repo" >/dev/null || exit 1
		[[ -f .gitmodules ]] && {
			git submodule init
			git submodule update --recursive
		}
		popd >/dev/null
	done
}

remove() {
	shift || exit 1
	path="clone/$1"
	[[ -d "${path}" ]] && {
		rm -rf "${path}"
	}
}

build() {
	shift || exit 1
	path="clone/$1"
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
build)
	build "$@"
	;;
*)
	{
		echo "options:"
		echo "  add <clone>"
		echo "  remove <clone>"
		echo ""
		echo "  build <clone>"
	} >&2
	exit 1
	;;
esac
popd >/dev/null
