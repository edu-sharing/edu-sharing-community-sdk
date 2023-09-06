FROM ${dockerImage}


ARG git_branch=dev
ARG git_closest_tag_fixed=dev
ARG git_commit_id=dev
ARG git_dirty=dev
ARG project_artifactId=${artifactId}
ARG project_groupId=org.edu_sharing
ARG project_version=dev

########################################################################################################################

# TODO default value substituion doesn't work because of the '.' delimiter
LABEL git.branch=${git_branch}
LABEL git.closest.tag.name=${git_closest_tag_fixed}
LABEL git.commit.id=${git_commit_id}
LABEL git.dirty=${git_dirty}
LABEL mvn.project.artifactId=${project_artifactId}
LABEL mvn.project.groupId=${project_groupId}
LABEL mvn.project.version=${project_version}

