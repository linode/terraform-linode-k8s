# Example Readme

A simple helm setup to confirm various pieces are working

- Traefik - Test Loadbalancer Service
- Wordpress - Something to look at
- mysql - Exercise CSI

Note: mysqlha chart is used only because it uses a stateful set

## Requirements

- [Helm binary and tiller on cluster](https://docs.helm.sh/using_helm/)

## Steps

- ./init.sh
- kubectl get pods -w
