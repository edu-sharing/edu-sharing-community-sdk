{{- define "edusharing_repository_search_solr6.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "edusharing_repository_search_solr6.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "edusharing_repository_search_solr6.labels" -}}
{{ include "edusharing_repository_search_solr6.labels.instance" . }}
helm.sh/chart: {{ include "edusharing_repository_search_solr6.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "edusharing_repository_search_solr6.labels.instance" -}}
{{ include "edusharing_repository_search_solr6.labels.app" . }}
{{ include "edusharing_repository_search_solr6.labels.version" . }}
{{- end -}}

{{- define "edusharing_repository_search_solr6.labels.version" -}}
version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

{{- define "edusharing_repository_search_solr6.labels.app" -}}
app: {{ include "edusharing_repository_search_solr6.name" . }}
app.kubernetes.io/name: {{ include "edusharing_repository_search_solr6.name" . }}
{{- end -}}
