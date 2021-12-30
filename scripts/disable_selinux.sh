echo "##############################################################"
echo 					"Disabling SELinux..."
echo "##############################################################"
sudo setenforce 0
sudo sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
echo "wating 5 seconds..."
sleep 5