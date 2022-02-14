# My additional notes

## Useful links

[markdown table generator](https://www.tablesgenerator.com/markdown_tables#)

[kubecolor](https://github.com/hidetatz/kubecolor)

[ArgoCD and kubeseal](https://devopstales.github.io/kubernetes/argocd-kubeseal/)

[argo-repo-server](https://github.com/danmanners/argocd-sops/pkgs/container/argo-repo-server)

## New network topology

| node  | ip address   | role   |
|-------|--------------|--------|
| k8s-0 | 192.168.1.10 | master |
| k8s-1 | 192.168.1.11 | master |
| k8s-2 | 192.168.1.12 | worker |
| k8s-3 | 192.168.1.13 | worker |

## Addons

<https://github.com/ahmetb/kubectx>

<https://github.com/junegunn/fzf>

## ArgoCD

Deploy ArgoCD (in this case HA)

```sh
kubectl create namespace argocd

kubectl apply -n argocd -f \
https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/ha/install.yaml
```

While the cluster prepares the deployment, it is a good time to get the [argocd cli](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

Next we will retrieve the admin password for ArgoCD

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

After this we will port forward (for the time being; assuming we do not have an index) ArgoCD. We can then access the server on localhost:8080. Credentials are _admin_ and the pw from the previous step.

```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
