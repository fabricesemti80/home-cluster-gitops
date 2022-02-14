# My additional notes

## Useful links

[markdown table generator](https://www.tablesgenerator.com/markdown_tables#)

[kubecolor](https://github.com/hidetatz/kubecolor)

[ArgoCD and kubeseal](https://devopstales.github.io/kubernetes/argocd-kubeseal/)

[argo-repo-server](https://github.com/danmanners/argocd-sops/pkgs/container/argo-repo-server)

[Store your Kubernetes Secrets in Git thanks to Kubeseal. Hello SealedSecret!](https://dev.to/stack-labs/store-your-kubernetes-secrets-in-git-thanks-to-kubeseal-hello-sealedsecret-2i6h)

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

## Additional programs

[Krew](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)

https://github.com/itaysk/kubectl-neat

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

## Sealed Secrets

Now we install the controller. The manifext is in  the `cluster/manifests/critical/sealed-secrets` folder.

Since at this point we have Argo, we will use it to deploy this.

- first we connect our repo - <https://github.com/fabricesemti80/home-cluster-gitops> - to ArgoCD using the GUI.

![link repo](https://imgur.com/BsZuz9T.png)

- next we create the application

![create application](https://imgur.com/tGeMYVe.png)

Most settings are optional, but make sure to select the right repo and path to the application

![sealed secrets 1](https://imgur.com/ZXsoW4I.png)

You should see this app being synced in a few minutes

![sealed secrets 2](https://imgur.com/HVXH407.png)

We can also verify this with kubectl

```sh
❯ kubectl get all -n kube-system
NAME                                            READY   STATUS    RESTARTS      AGE

...lots of other resources ommited...

pod/sealed-secrets-controller-567dbb5c9-njhth   1/1     Running   0             7m58s


❯ kubectl logs sealed-secrets-controller-567dbb5c9-njhth -n kube-system
controller version: 0.17.3
2022/02/14 19:05:45 Starting sealed-secrets controller version: 0.17.3
2022/02/14 19:05:45 Searching for existing private keys
2022/02/14 19:05:49 New key written to kube-system/sealed-secrets-keyw8rjl
2022/02/14 19:05:49 Certificate is
-----BEGIN CERTIFICATE-----

```

We then retrieve and securely store the public certificate.

```sh
home-cluster-gitops on  main [!]
❯ kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key
NAME                      TYPE                DATA   AGE
sealed-secrets-keyw8rjl   kubernetes.io/tls   2      12m

home-cluster-gitops on  main [!]
❯ kubectl get secret sealed-secrets-keyw8rjl -o yaml -n kube-system
apiVersion: v1
data:
... key data omited ...
```

Store this certificate somehow. For now I store it in a local file (backed up to my password manager)

```sh
home-cluster-gitops on  main [!]
❯ mkdir ~/.kubeseal  

home-cluster-gitops on  main [!]
❯ kubeseal --fetch-cert > ~/.kubeseal/mycert.pem

home-cluster-gitops on  main [!]
❯
```

Now, we can seal our secret.

In my case I already have the `secrets.yaml` _**(do not forget to exclude these from git commits! )**_ in the folder of the app, so I will just "seal" it:

```sh
home-cluster-gitops on  main [✘!+?] took 7s
❯ kubeseal --cert ~/.kubeseal/mycert.pem --format=yaml < cluster/manifests/networking/cloudflare-ddns/secrets.yaml > cluster/manifests/networking/cloudflare-ddns/sealedsecrets.yaml

home-cluster-gitops on  main [✘!+?]
❯
```

This should result in a sealed secret file

![sealed secret](https://imgur.com/x96JBYP.png)

Now we can deploy the app after pushing this to Github (do not forget to add `# yamllint disable`) to the file!
