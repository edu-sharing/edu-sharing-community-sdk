#!/bin/bash
set -eu

########################################################################################################################

my_bind="${REPOSITORY_SEARCH_SOLR_BIND:-"0.0.0.0"}"

my_host="${REPOSITORY_SEARCH_SOLR_HOST:-repository-search-solr}"
my_port="${REPOSITORY_SEARCH_SOLR_PORT:-8080}"

repository_service_host="${REPOSITORY_SERVICE_HOST:-repository-service}"
repository_service_port="${REPOSITORY_SERVICE_PORT:-8080}"

repository_service_base="http://${repository_service_host}:${repository_service_port}/edu-sharing"

solrBase="/opt/alfresco"
solrData="${solrBase}/alf_data"
solrHome="${solrBase}/solr/solrhome"
solrEnvs="${solrBase}/solr/solr.in.sh"
solrCoreTpl="${solrHome}/templates/rerank/conf/solrcore.properties"
solrSchemaTpl="${solrHome}/templates/rerank/conf/schema.xml"
solrConfShared="${solrHome}/conf/shared.properties"

### Wait ###############################################################################################################

until wait-for-it "${repository_service_host}:${repository_service_port}" -t 3; do sleep 1; done

until [[ $( curl -sSf -w "%{http_code}\n" -o /dev/null -H 'Accept: application/json' "${repository_service_base}/rest/_about/status/SERVICE?timeoutSeconds=3" ) -eq 200 ]]
do
  >&2 echo "Waiting for ${repository_service_host} ..."
  sleep 3
done

### Tomcat #############################################################################################################

export CATALINA_OUT="/dev/stdout"

export CATALINA_OPTS="-Dfile.encoding=UTF-8 $CATALINA_OPTS"
export CATALINA_OPTS="-Duser.country=DE $CATALINA_OPTS"
export CATALINA_OPTS="-Duser.language=de $CATALINA_OPTS"

### Alfresco solr #####################################################################################################

sed -i -r 's|^[#]*\s*alfresco\.host=.*|alfresco.host='"${repository_service_host}"'|' "${solrCoreTpl}"
grep -q '^[#]*\s*alfresco\.host=' "${solrCoreTpl}" || echo "alfresco.host=${repository_service_host}" >>"${solrCoreTpl}"

sed -i -r 's|^[#]*\s*alfresco\.port=.*|alfresco.port='"${repository_service_port}"'|' "${solrCoreTpl}"
grep -q '^[#]*\s*alfresco\.port=' "${solrCoreTpl}" || echo "alfresco.port=${repository_service_port}" >>"${solrCoreTpl}"

sed -i -r 's|^[#]*\s*alfresco\.secureComms=.*|alfresco.secureComms=none|' "${solrCoreTpl}"
grep -q '^[#]*\s*alfresco\.secureComms=' "${solrCoreTpl}" || echo "alfresco.secureComms=none" >>"${solrCoreTpl}"

sed -i -r 's|^[#]*\s*alfresco\.encryption\.ssl\.keystore\.location=.*|alfresco.encryption.ssl.keystore.location='"${solrHome}"'/keystore/ssl.repo.client.keystore|' "${solrCoreTpl}"
grep -q   '^[#]*\s*alfresco\.encryption\.ssl\.keystore\.location=' "${solrCoreTpl}" || echo "alfresco.encryption.ssl.keystore.location=${solrHome}/keystore/ssl.repo.client.keystore" >> "${solrCoreTpl}"

sed -i -r 's|^[#]*\s*alfresco\.encryption\.ssl\.truststore\.location=.*|alfresco.encryption.ssl.truststore.location='"${solrHome}"'/keystore/ssl.repo.client.truststore|' "${solrCoreTpl}"
grep -q   '^[#]*\s*alfresco\.encryption\.ssl\.truststore\.location=' "${solrCoreTpl}" || echo "alfresco.encryption.ssl.truststore.location=${solrHome}/keystore/ssl.repo.client.truststore" >> "${solrCoreTpl}"

sed -i -r 's|^[#]*\s*data\.dir\.root=.*|data.dir.root='"${solrData}"'|' "${solrCoreTpl}"
grep -q '^[#]*\s*data\.dir\.root=' "${solrCoreTpl}" || echo "data.dir.root=${solrData}" >>"${solrCoreTpl}"

#enable multi language search support
sed -i -r 's|^[#]*\s*alfresco\.cross\.locale\.datatype\.0=.*|alfresco.cross.locale.datatype.0={http://www.alfresco.org/model/dictionary/1.0}text|' "${solrConfShared}"
grep -q '^[#]*\s*alfresco\.cross\.locale\.datatype\.0=' "${solrConfShared}" || echo "alfresco.cross.locale.datatype.0={http://www.alfresco.org/model/dictionary/1.0}text" >>"${solrConfShared}"

sed -i -r 's|^[#]*\s*alfresco\.cross\.locale\.datatype\.1=.*|alfresco.cross.locale.datatype.1={http://www.alfresco.org/model/dictionary/1.0}content|' "${solrConfShared}"
grep -q '^[#]*\s*alfresco\.cross\.locale\.datatype\.1=' "${solrConfShared}" || echo "alfresco.cross.locale.datatype.1={http://www.alfresco.org/model/dictionary/1.0}content" >>"${solrConfShared}"

sed -i -r 's|^[#]*\s*alfresco\.cross\.locale\.datatype\.2=.*|alfresco.cross.locale.datatype.2={http://www.alfresco.org/model/dictionary/1.0}mltext|' "${solrConfShared}"
grep -q '^[#]*\s*alfresco\.cross\.locale\.datatype\.2=' "${solrConfShared}" || echo "alfresco.cross.locale.datatype.2={http://www.alfresco.org/model/dictionary/1.0}mltext" >>"${solrConfShared}"

########################################################################################################################

#change type stripLocaleStrField to prevent cclom:general_keyword not indexed: Caused by: java.lang.ClassCastException: Cannot cast java.util.ArrayList to java.lang.String
xmlstarlet ed -L -u "/schema/fields/dynamicField[@name='mltext@m____@*']/@type" -v 'alfrescoFieldType' ${solrSchemaTpl}

exec "$@"
