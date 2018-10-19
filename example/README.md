# Example Readme

A simple helm setup to confirm various pieces are working

- Traefik - Test Loadbalancer Service
- Wordpress - Something to look at
- mysql - Exercise CSI

## Requirements

- [Helm binary and tiller on cluster](https://docs.helm.sh/using_helm/)
- A domain that be safely overwritten by external-dns

## Steps

- export DOMAIN=example.com
- ./init.sh
- kubectl get pods -w

Navigate to

- wordpress.example.com
- traefik.example.com (Traefik admin dashboard)

## Notes

- mysqlha chart is used because it is a stateful set
- traefik acme staging is intentionally set to true
