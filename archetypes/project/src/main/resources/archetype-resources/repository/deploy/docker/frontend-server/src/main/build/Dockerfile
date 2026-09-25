FROM ${docker.from}community/edu_sharing-community-repository-deploy-docker-build-frontend-server:${org.edu_sharing:edu_sharing-community-repository-deploy-docker-build-frontend-server:jar:sources.version}

########################################################################################################################

# the server itself stays the community one - only the angular app is replaced by the
# project build (community app + project customizations, see repository/Frontend)

USER root

RUN set -eux \
    && rm -rf /app/dist

COPY --chown=node:node dist /app/dist

########################################################################################################################

USER node

########################################################################################################################

LABEL git.branch=${git.branch} \
git.closest.tag.name=${git.closest.tag.fixed} \
git.commit.id=${git.commit.id} \
git.dirty=${git.dirty} \
mvn.project.artifactId=${project.artifactId} \
mvn.project.groupId=${project.groupId} \
mvn.project.version=${project.version}
