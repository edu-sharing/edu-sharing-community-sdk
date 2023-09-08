FROM ${docker.from.openjdk.11}

########################################################################################################################

RUN set -eux \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        jq \
        wait-for-it \
        xmlstarlet \
        procps \
        lsof \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

########################################################################################################################

ENV ALF_HOME /opt/alfresco
ENV PATH $ALF_HOME/bin:$ALF_HOME/solr/bin:$PATH

WORKDIR $ALF_HOME

COPY assets/entrypoint.sh bin/

RUN set -eux \
	&& find bin -type f -name '*.sh' -exec chmod +x {} \;

RUN set -eux \
    && adduser --uid=1000 --home=$ALF_HOME --disabled-password --gecos "" --shell=/bin/bash worker \
    && chown -RL worker:worker /tmp \
    && mkdir -p alf_data \
    && chown -RL worker:worker .

USER worker

### Alfresco solr #####################################################################################################

COPY --chown=worker:worker artifacts/alfresco-search-services-${org.alfresco:alfresco-search-services:zip.version}.zip /tmp/alfresco-search-services.zip

RUN set -eux \
	&& mkdir -p /tmp/install/alfresco-search-services \
	&& unzip /tmp/alfresco-search-services.zip -d /tmp/install/alfresco-search-services \
	&& rm -f /tmp/alfresco-search-services.zip \
	&& mkdir -p alf_data \
	&& mkdir -p solr \
    && mv /tmp/install/alfresco-search-services/alfresco-search-services/* solr

COPY --chown=worker:worker assets/keystores/solr/ solr/solrhome/keystore/

COPY --chown=worker:worker assets/security.json solr/solrhome/security.json

########################################################################################################################

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]
CMD ["solr/solr/bin/solr", "start", "-f","-p","8080", "-Dcreate.alfresco.defaults=alfresco,archive"]

VOLUME [ "/opt/alfresco/alf_data" ]

########################################################################################################################

LABEL git.branch=${git.branch}
LABEL git.closest.tag.name=${git.closest.tag.fixed}
LABEL git.commit.id=${git.commit.id}
LABEL git.dirty=${git.dirty}
LABEL mvn.project.artifactId=${project.artifactId}
LABEL mvn.project.groupId=${project.groupId}
LABEL mvn.project.version=${project.version}
