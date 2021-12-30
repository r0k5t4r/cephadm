osdnodes="osd1 osd2 osd3"
# permit root login via ssh
for node in $osdnodes; do ssh $node "sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config"; done
# set root password to "root". !!! do not do this on a production environment !!!
for node in $osdnodes; do ssh $node "echo "root" | sudo passwd --stdin root"; done
# copy the ceph.key to the osd node
for node in $osdnodes; do ssh-copy-id -f -i /etc/ceph/ceph.pub root@$node; done


Download the CEPH private key and config file. You can use the private key for subsequent commands.

sudo ceph cephadm get-ssh-config > ssh_config
sudo ceph config-key get mgr/cephadm/ssh_identity_key > key
sudo chmod 0600 key

sudo ceph orch host add osd1 192.168.0.51
sudo ceph orch host add osd2 192.168.0.52
sudo ceph orch host add osd3 192.168.0.53