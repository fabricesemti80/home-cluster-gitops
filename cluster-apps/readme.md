# Create this app via the ArgoCD GUI

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-apps
spec:
  destination:
    namespace: default
    server: 'https://kubernetes.default.svc'
  source:
    path: cluster-apps
    repoURL: 'https://github.com/fabricesemti80/home-cluster-gitops.git'
    targetRevision: HEAD
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
