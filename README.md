# Notes

For the notes regarding the template, please visit: <https://github.com/k8s-at-home/template-cluster-k3s>

## Useful links

[markdown table generator](https://www.tablesgenerator.com/markdown_tables#)

[kubecolor](https://github.com/hidetatz/kubecolor)

[k8s-at-home helm reference](https://github.com/k8s-at-home/library-charts/blob/main/charts/stable/common/values.yaml)

[material icons - for Hajimari](https://materialdesignicons.com/)

## Network topology

| node  | ip address   | role   |
|-------|--------------|--------|
| k8s-0 | 192.168.1.10 | master |
| k8s-1 | 192.168.1.11 | master |
| k8s-2 | 192.168.1.12 | worker |
| k8s-3 | 192.168.1.13 | worker |
| k8s-4 | 192.168.1.14 | worker |

### Networking


Ensure that the k8s servers have the same named network interfaces (this is important for kubevip).

Elevate your session

```sh
sudo su
```

Create netplan

```yaml
---
#! /bin/bash
var=/etc/netplan/01-network-manager-all.yaml
cat << EOF > $var
# Let NetworkManager manage all devices on this system
# ref: https://askubuntu.com/questions/1317036/how-to-rename-a-network-interface-in-20-04
# update madaddress (and add further interfaces, if you have any) accordingly
# sudo nano /etc/netplan/01-network-manager-all.yaml
  network:
    version: 2
    ethernets:
        eth0:
            addresses:
            #TODO: upate this for the selected IP of the host
            - 192.168.1.22/16
            gateway4: 192.168.1.1
            nameservers:
                addresses:
                - 192.168.1.1
                - 208.67.222.222
                - 208.67.220.220
                search: []
            match:
                #TODO: upate this for the active NIC of the host
                macaddress: b0:83:fe:ba:ac:d8
            set-name: eth0
        # eth1:
            # dhcp4: true
            # match:
                # macaddress: 2c:4d:54:65:3d:eb
            # set-name: eth1
EOF
```
Apply this config and reboot

```sh
netplan apply && reboot
```

After the system restarted, you should be able to log in with the new IP remotely.

## Addons

[Kubectx](https://github.com/ahmetb/kubectx)
[k9s](https://k9scli.io/)

## Deployment

1. First we follow the steps detailed in <https://github.com/k8s-at-home/template-cluster-k3s>

2. Next, as we have a few additional secrets and settings, we need to update the following files:

    - cluster/base/cluster-secrets.sops.yaml
    - cluster/base/cluster-settings.yaml

3. Most secrets come from these files, and thanks to the [reflector](https://github.com/emberstack/kubernetes-reflector) are mirrored to the relevant namespaces.
However currently - March 2022 - there are a a few apps that require their own separate secrets:

- [vpn-gateway](https://github.com/k8s-at-home/pod-gateway) - `cluster/core/vpn-gateway`
- [flux notifications](https://fluxcd.io/docs/guides/notifications/) - `cluster/base/flux-system/notifications`

    The secrets within these folders need to be manually re-created and re-encrypted (with [sops](https://github.com/mozilla/sops))


## Portainer oauth2

Portainer integrates with (Google) oauth2, therefore you can add this within the ap, does not need to have the Traefik oauth frontend.

To do this, when the app is deployed, log in (cretate admin account for basic auth) and enable settings > oauth.

![Add a user](hack/portainer1.png "Adding user in Portainer")

Then set up oauth (you will need to have a prject in Google Cloud platform, which is outside the scope of this guide)

![Oauth2 settings in Portainer](hack/portainer2.png "Oauth2 settings in Portainer")

(1) get these from the Google project

(2) address of the server; on the project you need to add this as an allowed redirect URL!


## Inspiration / credits

<https://github.com/spacesyl/klus>
