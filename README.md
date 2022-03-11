# My additional notes

For the notes regarding the template, please visit: <https://github.com/k8s-at-home/template-cluster-k3s>

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

Install the Sealed Secrets manifests.

use [kubeseal]() to save the encryption certificate to a file

```sh
kubeseal --fetch-cert > ~/.kubeseal/mycert.pem  
```

Export the certificate to an env var (add to your profile or use [direnv](https://direnv.net/) )

```sh
export SEALED_SECRETS_CERT=~/.kubeseal/mycert.pem
```

After this you should be able to encrypt your secrets (_just do not forget to exclude the original from the Git repo!!!_) with either of these methods...

```sh
# giving path to the cert file
home-cluster-gitops/cluster-init/argo-cd on  argocd [!?]
❯ kubeseal --cert ~/.kubeseal/mycert.pem --format=yaml < /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.yaml > /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.sealed.yaml

# storing the path of the cert in an env var
home-cluster-gitops/cluster-init/argo-cd on  argocd [!?]
❯ kubeseal --cert $SEALED_SECRETS_CERT --format=yaml < /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.yaml > /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.sealed.yaml

# if the path is in an env var, you do not even have to specify the --cert option
home-cluster-gitops/cluster-init/argo-cd on  argocd [!?]
❯ kubeseal  --format=yaml < /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.yaml > /home/fabrice/Projects/home-cluster-gitops/cluster-init/argo-cd/my-token.sealed.yaml  
````

...or use the [vascode extension](https://marketplace.visualstudio.com/items?itemName=codecontemplator.kubeseal) to do this.


## ArgoCD

Install ArgoCD as per [this](https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd). Need the `chart.yaml` and the `values.yaml` of course!

Complete installation:

```sh
home-cluster-gitops on  argocd [✘»+]
❯ helm repo add argo https://argoproj.github.io/argo-helm # here we add the original repository
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/fabrice/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/fabrice/.kube/config
"argo" already exists with the same configuration, skipping # whoops, looks like I already added it (it is actually a re-install :D )

home-cluster-gitops on  argocd [✘»+]
❯ helm search repo argo # here we check what is in the repo; we only interested in the  argo/argo-cd chart  
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/fabrice/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/fabrice/.kube/config
NAME                      	CHART VERSION	APP VERSION  	DESCRIPTION  
argo/argo                 	1.0.0        	v2.12.5      	A Helm chart for Argo Workflows  
argo/argo-cd              	3.33.5       	v2.2.5       	A Helm chart for ArgoCD, a declarative, GitOps ...
argo/argo-ci              	1.0.0        	v1.0.0-alpha2	A Helm chart for Argo-CI  
argo/argo-events          	1.10.2       	v1.5.6       	A Helm chart to install Argo-Events in k8s Cluster
argo/argo-lite            	0.1.0        	             	Lighweight workflow engine for Kubernetes  
argo/argo-rollouts        	2.9.3        	v1.1.1       	A Helm chart for Argo Rollouts  
argo/argo-workflows       	0.10.1       	v3.2.7       	A Helm chart for Argo Workflows  
argo/argocd-applicationset	1.9.1        	v0.3.0       	A Helm chart for installing ArgoCD ApplicationSet
argo/argocd-image-updater 	0.6.2        	v0.11.2      	A Helm chart for Argo CD Image Updater, a tool ...
argo/argocd-notifications 	1.8.0        	v1.2.1       	A Helm chart for ArgoCD notifications, an add-o...

home-cluster-gitops on  argocd [✘»+]
❯ helm repo update argo # upgrade the repo to get the latest charts  
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/fabrice/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/fabrice/.kube/config
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "argo" chart repository
Update Complete. ⎈Happy Helming!⎈

home-cluster-gitops on  argocd [✘»+]
❯ helm install argocd argo/argo-cd -n argocd --create-namespace  
# her I am installing the chart with the default values
# I could add my values with the "--values"  switch, but for the time being this is a test install so I am good with the defaults  
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/fabrice/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/fabrice/.kube/config
NAME: argocd
LAST DEPLOYED: Tue Feb 15 19:12:26 2022
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
In order to access the server UI you have the following options:

1. kubectl port-forward service/argocd-server -n argocd 8080:443

    and then open the browser on http://localhost:8080 and accept the certificate

2. enable ingress in the values file `server.ingress.enabled` and either
      - Add the annotation for ssl passthrough: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-1-ssl-passthrough
      - Add the `--insecure` flag to `server.extraArgs` in the values file and terminate SSL at your ingress: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-2-multiple-ingress-objects-and-hosts


After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://github.com/argoproj/argo-cd/blob/master/docs/getting_started.md#4-login-using-the-cli)

home-cluster-gitops on  argocd [✘»+]
❯ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d # then we get the password and log in
<something supper secret!>

```

_note: because of the parameters, it will also create the namespace if neccesary!_

_note 2: follow the instructions in order to log in. Advisable to crete a new account. Also note: for me the command added an extra `%` at the end of the password!_
