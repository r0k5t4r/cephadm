# cephadm

## Delete OSDs
### see: https://docs.ceph.com/en/quincy/cephadm/services/osd/
sudo ceph osd ls --refresh --wide
sudo ceph osd destroy 0 --yes-i-really-mean-it
sudo ceph osd out 0
sudo ceph osd purge 0 --yes-i-really-mean-it
sudo ceph orch daemon rm osd.0 --force
sudo ceph orch osd rm status

## In case the osd is not correctly deleted from the node, you can run the following

### on the node
reboot
sudo wipefs -af /dev/sdX

### on the bootstrap node
sudo ceph orch device ls --refresh

### remove service
sudo ceph orch ls
sudo ceph orch ls osd
sudo ceph orch ls osd osd.cost_capacity
sudo ceph orch ls osd osd.cost_capacity --export yaml > osd.cost_cap.yaml

### edit the yaml and add unmanged: true
sudo ceph orch apply -i osd.cost_cap.yaml