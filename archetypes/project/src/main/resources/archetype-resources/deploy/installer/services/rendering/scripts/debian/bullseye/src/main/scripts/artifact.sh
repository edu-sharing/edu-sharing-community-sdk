#set( $symbol_pound = '#' )
#set( $symbol_dollar = '$' )
#set( $symbol_escape = '\' )
${symbol_pound}!/bin/bash
set -e
set -o pipefail

export ARTIFACT_ID="${rootArtifactId}-deploy-installer-services-rendering-distribution"
export ARTIFACT_VERSION="${symbol_dollar}{org.edu_sharing:${rootArtifactId}-deploy-installer-services-rendering-distribution:tar.gz:bin.version}"