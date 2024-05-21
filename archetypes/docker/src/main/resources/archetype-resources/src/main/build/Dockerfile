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
LABEL git.branch=${git_branch} \
git.closest.tag.name=${git_closest_tag_fixed} \
git.commit.id=${git_commit_id} \
git.dirty=${git_dirty} \
mvn.project.artifactId=${project_artifactId} \
mvn.project.groupId=${project_groupId} \
mvn.project.version=${project_version}

