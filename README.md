# Stackdriver Kubernetes Configs

A collection of kubernetes configurations to integrate with Stackdriver
products. For now, it supports [Stackdriver Logging](https://cloud.google.com/logging/)
and [Stackdriver Monitoring](https://cloud.google.com/monitoring/). This repo is only used
for [manual installation](https://cloud.google.com/monitoring/kubernetes-engine/customizing) 
on existing clusters.

## Setting up git hooks

From the root directory of this repo, please run the following command:

```
ln -s "$(realpath hooks/pre-commit)" "$(git rev-parse --git-dir)/hooks/pre-commit"
```

This will ensure that all commits run the
[`compile-agents-yaml.sh`](#compile-agents-yaml) command.

## Compile Agents YAML<a name="compile-agents-yaml"></a>

From the root directory of this repo, you can run the following command:

```
./compile-agents-yaml.sh
```

This will ensure that all commits re-generate the `agents.yaml` file to keep it
up-to-date with other YAML file changes.

