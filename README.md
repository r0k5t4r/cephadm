# cephadm

## Delete OSDs

sudo ceph osd ls
sudo ceph osd destroy 0 --yes-i-really-mean-it
sudo ceph osd out 1
sudo ceph osd purge 0 --yes-i-really-mean-it
sudo ceph orch daemon rm osd.3 --force