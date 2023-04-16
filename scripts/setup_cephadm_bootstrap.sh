#VARS
cephrel="pacific"

echo "##############################################################"
echo                      "Setting up cephadm"
echo "##############################################################"

echo "Installing Epel..."
sudo yum -y install epel-release
echo "Installing sshpass..."
sudo yum --enablerepo=epel -y install sshpass
echo "Generating SSH keypar"
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
#echo "vagrant" > password.txt
echo "cephadm123" > password.txt
nodes="bootstrap osd1 osd2 osd3"
echo "Copying SSH public key to all nodes"
for node in $nodes; do ping -qc1 $node && sshpass -f password.txt ssh-copy-id -o stricthostkeychecking=false root@$node; done
echo "Installing prerequisites podman lvm2 pyhton3 on all nodes..."
for node in $nodes; do ssh root@$node "sudo yum -y install podman lvm2 python3"; done

echo "Downloading cephadm..."
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/$cephrel/src/cephadm/cephadm
chmod +x cephadm

echo "Enabling ceph $cephrel repos..."
sudo ./cephadm add-repo --release $cephrel

echo "Installing ceph $cephrel..."
sudo ./cephadm install

echo "Installing ceph-common package..."
sudo cephadm install ceph-common

echo "Creating configuration directory and initial config..."
sudo mkdir -p /etc/ceph
cat > initial-ceph.conf <<EOF
[global]
 public network = 192.168.2.0/24
 cluster network = 192.168.0.0/24
EOF
sudo mv initial-ceph.conf /root

echo "Bootstrapping CEPH Cluster..."
sudo cephadm bootstrap --config /root/initial-ceph.conf --mon-ip 192.168.2.200
#sudo cephadm bootstrap --config /root/initial-ceph.conf --mon-ip 192.168.2.200 --cluster-network 192.168.41.0/24