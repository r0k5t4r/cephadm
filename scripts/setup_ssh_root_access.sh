# This script changes sshd config to permit ssh root log in and changes the root password to cephadm123
echo "##############################################################"
echo 					"Configuring SSH..."
echo "##############################################################"
echo "Permitting Root Login..."
sudo sed -i --follow-symlinks 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
echo "Enabling Password Authentication"
sudo sed -i --follow-symlinks 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
echo "Restarting ssh daemon..."
sudo systemctl restart sshd && echo "SSH successfully configured."
#sudo service sshd reload && echo "SSH successfully configured."
echo "Changing root password to cephadm123."
PASSWORD="cephadm123"
echo -e "$PASSWORD\n$PASSWORD" | sudo passwd root
echo "wating 3 seconds..."
sleep 3