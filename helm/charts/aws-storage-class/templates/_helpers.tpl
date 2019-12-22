{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s" $name | trunc 24 | trimSuffix "-" -}}
{{- end -}}

{{/*
EBS Storage class for each zone
*/}}
{{- define "aws_ebs" -}}
{{ range $zone := .Values.cloudProviders.aws.zones }}
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: {{ printf "ssd-%s" $zone }}
provisioner: kubernetes.io/aws-ebs
reclaimPolicy: Retain
parameters:
  type: gp2
  zones: {{ $zone }}
---
{{ end }}
{{- end -}}
