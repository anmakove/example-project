{{/* vim: set filetype=mustache: */}}
{{/*
Use app.name the same as app.fullname if nameOverride does not exist
*/}}
{{- define "app.name" -}}
{{- default (include "app.fullname" .) .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Use release name as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
app.kubernetes.io/name: {{ include "app.fullname" . }}
app: {{ include "app.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/project-type: {{ .Values.projectType }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{- default (include "app.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role to use
*/}}
{{- define "app.clusterRoleName" -}}
    {{- default (include "app.fullname" .) .Values.serviceAccount.clusterRole.roleName -}}
{{- end -}}

{{/*
Create the name of the cluster role binding to use
*/}}
{{- define "app.clusterRoleBindingName" -}}
    {{- default (include "app.fullname" .) .Values.serviceAccount.clusterRole.bindingName -}}
{{- end -}}

{{/*
Compute the short name of service without "service" suffix
*/}}
{{- define "app.shortname" -}}
    {{- print (include "app.fullname" .) | trimSuffix "-service" | replace "-" "_"  -}}
{{- end -}}

{{/*
Compute the short name of service without "service" suffix
*/}}
{{- define "app.ingressDefaultHostname" -}}
    {{- print (include "app.fullname" .) | trimSuffix "-service" -}}
{{- end -}}

{{/*
Common ingress annotations
*/}}
{{- define "app.ingressInternal.annotations" -}}
kubernetes.io/ingress.class: "{{ .Values.api.ingressInternal.ingressClass | default "alb" }}"
alb.ingress.kubernetes.io/group.name: "{{ .Values.api.ingressInternal.groupName | default "api" }}"
alb.ingress.kubernetes.io/scheme: "{{ .Values.api.ingressInternal.scheme | default "internal" }}"
alb.ingress.kubernetes.io/target-type: "{{ .Values.api.ingressInternal.targetType | default "ip" }}"
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
alb.ingress.kubernetes.io/ssl-policy: "{{ .Values.api.ingressInternal.sslPolicy }}"
alb.ingress.kubernetes.io/healthcheck-path: "{{ .Values.api.ingressInternal.healthcheckPath }}"
alb.ingress.kubernetes.io/healthcheck-interval-seconds: "{{ .Values.api.ingressInternal.healthcheckInterval }}"
alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "{{ .Values.api.ingressInternal.healthcheckTimeout }}"
alb.ingress.kubernetes.io/healthy-threshold-count: "{{ .Values.api.ingressInternal.healthyThreshold }}"
alb.ingress.kubernetes.io/unhealthy-threshold-count: "{{ .Values.api.ingressInternal.unhealthyThreshold }}"
alb.ingress.kubernetes.io/tags: "{{ .Values.api.ingressInternal.tags | default "lb-scheme=internal" }}"
alb.ingress.kubernetes.io/target-group-attributes: load_balancing.algorithm.type=weighted_random,load_balancing.algorithm.anomaly_mitigation=on
{{- if (and .Values.api.ingressInternal.albAccessLogs .Values.api.ingressInternal.albAccessLogs.enabled) }}
alb.ingress.kubernetes.io/load-balancer-attributes: "access_logs.s3.enabled={{ .Values.api.ingressInternal.albAccessLogs.enabled }},access_logs.s3.bucket={{ .Values.api.ingressInternal.albAccessLogs.s3BucketName }},access_logs.s3.prefix=api-int"
{{- end }}
{{- if .Values.api.ingressInternal.customAnnotations }}
{{ .Values.api.ingressInternal.customAnnotations | toYaml }}
{{- end }}
{{- end -}}

{{- define "app.ingressExternal.annotations" -}}
kubernetes.io/ingress.class: "{{ .Values.api.ingressExternal.ingressClass | default "alb" }}"
alb.ingress.kubernetes.io/scheme: "{{ .Values.api.ingressExternal.scheme | default "internet-facing" }}"
alb.ingress.kubernetes.io/target-type: "{{ .Values.api.ingressExternal.targetType | default "ip" }}"
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
alb.ingress.kubernetes.io/ssl-policy: "{{ .Values.api.ingressExternal.sslPolicy }}"
alb.ingress.kubernetes.io/healthcheck-path: "{{ .Values.api.ingressExternal.healthcheckPath }}"
alb.ingress.kubernetes.io/healthcheck-interval-seconds: "{{ .Values.api.ingressExternal.healthcheckInterval }}"
alb.ingress.kubernetes.io/healthcheck-timeout-seconds: "{{ .Values.api.ingressExternal.healthcheckTimeout }}"
alb.ingress.kubernetes.io/healthy-threshold-count: "{{ .Values.api.ingressExternal.healthyThreshold }}"
alb.ingress.kubernetes.io/unhealthy-threshold-count: "{{ .Values.api.ingressExternal.unhealthyThreshold }}"
alb.ingress.kubernetes.io/target-group-attributes: load_balancing.algorithm.type=weighted_random,load_balancing.algorithm.anomaly_mitigation=on
{{- if (and .Values.api.ingressExternal.albAccessLogs .Values.api.ingressExternal.albAccessLogs.enabled) }}
alb.ingress.kubernetes.io/load-balancer-attributes: "access_logs.s3.enabled={{ .Values.api.ingressExternal.albAccessLogs.enabled }},access_logs.s3.bucket={{ .Values.api.ingressExternal.albAccessLogs.s3BucketName }},access_logs.s3.prefix={{ include "app.fullname" . }}"
{{- end }}
{{- if .Values.api.ingressExternal.customAnnotations }}
{{ .Values.api.ingressExternal.customAnnotations | toYaml }}
{{- end }}
{{- end -}}

{{/*
Common deployment annotations
*/}}
{{- define "app.deployment.annotations" -}}
reloader.stakater.com/auto: "true"
{{- end -}}

{{/*
Define name of service role in Vault
*/}}
{{- define "app.vaultRole" -}}
default-service-role
{{- end -}}

{{- define "app.envprefix" -}}
{{- if .Values.app.envPrefix -}}
{{- if eq .Values.app.envPrefix "" -}}
{{ default "" }}
{{- else -}}
{{ printf "%s_" .Values.app.envPrefix }}
{{- end -}}
{{- end -}}
{{- end -}}
