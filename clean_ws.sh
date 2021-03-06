#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Remove the kubernetes packages and other old packages"
apt remove -y kubectl kubernetes filebeat quagga

echo "Remove the unnecessary repos from system"
rm -fv /etc/apt/sources.list.d/*shift*

echo "Stop and remove the kubernetes services"
for service in kubelet kube-proxy; do
    systemctl stop ${service}
    systemctl disable ${service}
    rm -f /etc/systemd/system/${service}
    rm -f /etc/systemd/system/${service} # and symlinks that might be related
    rm -f /usr/lib/systemd/system/${service} 
    rm -f /usr/lib/systemd/system/${service} # and symlinks that might be related
done
systemctl daemon-reload
systemctl reset-failed

echo "Delete unneeded GPG key"
apt-key del 574E4513ACDFDF63

echo "Delete tls keys"
rm -rf /etc/?????shift/tls
rm -rf /etc/docker/certs.d/*shift*

echo "Fix the resolv.conf file"
sed 's/^\(.*\) .*svc\.ru-nsk-1\.k8s\(.*$\)/\1 \2/' -i /etc/resolv.conf
sed 's/^\(.*\) .*test\.k8s\..\{5\}shift\.net\(.*$\)/\1 \2/' -i /etc/resolv.conf

echo "Delete kubernetes dirs"
rm -rf /etc/kubernetes /etc/kubernetes-node /var/lib/kubelet /root/.docker/config.json /data/kube-nfs-storage

echo "Clean the export NFS confing file"
sed '/kube-nfs-storage/d' -i /etc/exports
exportfs -r

echo "Delete CNI confgin files"
rm -f /etc/cni/net.d/*weave*

echo "Clean the docker from ALL images, containers, volumes etc"
service docker stop
rm -rf /var/lib/docker/*
service docker start

echo -e "If you are wanna clean your system you can start the command below to:
'delete the packages were automatically installed and are no longer required'\n
sudo apt autoremove -y"
