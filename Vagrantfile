#!/usr/bin/ruby
# Below you can define specific parameters for each individual VM to be deployed by Vagrant.
# ip = assign this static IP
# box = which vagrant box should be deployed
# osd = configure an additonal virtual disk
# osdsize = size of the additional virtual disk in GB
# the remaining parameters should be pretty much self explanatory :)
# run the following to fix vagrant ssh issue
# set VAGRANT_PREFER_SYSTEM_BIN=0
# https://stackoverflow.com/questions/51437693/permission-denied-with-vagrant
nodes = [
  { :hostname => 'osd1',  		:ip => '192.168.2.201', :box => 'rockylinux/8', :clone_from => 'template-rocky8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20', :esxi => 'yes' },
  { :hostname => 'osd2',  		:ip => '192.168.2.202', :box => 'rockylinux/8', :clone_from => 'template-rocky8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20', :esxi => 'yes' },
  { :hostname => 'osd3',  		:ip => '192.168.2.203', :box => 'rockylinux/8', :clone_from => 'template-rocky8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20', :esxi => 'yes' },
  { :hostname => 'bootstrap', 	:ip => '192.168.2.200', :box => 'rockylinux/8', :clone_from => 'template-rocky8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20', :esxi => 'yes' }, 																																																													  																																																													  
]

varDomain = "fritz.box"
varRepository = "files"					   
$logger = Log4r::Logger.new('vagrantfile')
																										
def read_ip_address(machine)
																											 
  command = "hostname -I | cut -d ' ' -f 2"
  result  = ""

  $logger.info "Processing #{ machine.name } ... "

  begin
    # sudo is needed for ifconfig
    machine.communicate.sudo(command) do |type, data|
      result << data if type == :stdout
    end
    $logger.info "Processing #{ machine.name } ... success"
  rescue
    result = "# NOT-UP"
    $logger.info "Processing #{ machine.name } ... not running"
  end
													   
									
  result.chomp
end

Vagrant.configure("2") do |config|
	config.vm.synced_folder('.', '/vagrant', type: 'nfs', disabled: true)
	config.vm.synced_folder('.', '/Vagrantfiles', type: 'rsync', disabled: false)
	config.vm.boot_timeout = 600
	nodes.each do |node|
		config.vm.define node[:hostname] do |node_config| 
			# here we declare variables to use the values defined above in the nodes section, in case no values are defined, we set a default value
			memory = node[:ram] ? node[:ram] : 512;
			osddisksize = node[:osdsize] ? node[:osdsize] : 10;
			vcpus = node[:cpus] ? node[:cpus] : 1;
			vmbox = node[:clone_from] ? 'esxi_clone/dummy' : node[:box];																	  
			node_config.vm.box = vmbox
			#node_config.hostmanager.aliases = "#{node[:hostname]}"
			#node_config.hostmanager.aliases = "#{node[:hostname]}.#{varDomain}"
			#node_config.vm.hostname = node[:hostname]
			node_config.vm.hostname = node[:hostname]
			node_config.vm.network 'public_network', ip: node[:ip], netmask: '255.255.255.0'
	  
			# this script is no longer required since there is now a centos 8 stream vagrant box available
			#node_config.vm.provision "init0", type: "shell", path: "scripts/convert_to_centos_stream.sh"
			# ******************************* THE FOLLOWING SCRIPTS ARE MANDATORY *************************************
			# enable root access via ssh, root password will be set to cephadm123, you can change this in the script
			node_config.vm.provision "init1", before: "init2", type: "shell", path: "scripts/setup_ssh_root_access.sh"
			# disable IPv6	
			node_config.vm.provision "init2", type: "shell", path: "scripts/disable_ipv6.sh"
			# disable SELinux
			node_config.vm.provision "init3", type: "shell", path: "scripts/disable_selinux.sh"
			# *********************************************************************************************************

			if node[:esxi] == "yes"
				node_config.vm.provider :vmware_esxi do |esxi|
					esxi.esxi_hostname = '192.168.2.10'
					esxi.esxi_username = 'root'
					esxi.esxi_password = 'file:'
					esxi.clone_from_vm = node[:clone_from]
					esxi.esxi_resource_pool = "/"
					esxi.esxi_disk_store = 'truenas_ssd_01'
					esxi.esxi_virtual_network = ['VM Network','VM Network','VM Network']
					esxi.guest_memsize = memory.to_s
					esxi.guest_numvcpus = vcpus.to_s
					esxi.local_allow_overwrite = 'True'
					esxi.guest_nic_type = 'vmxnet3'
					#esxi.local_use_ip_cache = 'False'
					esxi.debug = 'true'
					esxi.vmkfstools = 'false'
					if node[:hv] == "yes"
						esxi.guest_custom_vmx_settings = [['vhv.enable','TRUE']]
					end #if node[:hv] == "yes"
				end #node_config.vm.provider :vmware_esxi do |esxi|
			end #if node[:esxi] == "yes"					  
			if node[:esxi] == "no"							 
				node_config.vm.provider :virtualbox do |v|
					v.name = node[:hostname]
					# here we customize our virtual box vm using the values from the variables
					v.customize ["modifyvm", :id, "--memory", memory.to_s]
					v.customize ["modifyvm", :id, "--cpus", vcpus.to_s]
		
					if node[:osd] == "yes"
						# If osd is set to 'yes' then add an additional virtual disk to IDE controller on port 1 device 0
						# In case you use different Vagrant Boxes, and you receive an error like Stderr: voxManage: error: Could not find a controller named 'IDE', this is caused by the fact that the Vagrant Box uses a different type of disk controller.
						# You can lookup the correct name and settings of the controller using the following voxmanage commands
						# Show all VMs
						# voxManage list vms
						# Show the Storage of a particular VM
						# voxmanage showvminfo 40aa7691-a75f-4e5a-99fb-135fc0295858 | findstr Storage
						osddisksizei = osddisksize.to_i
						osddisksizea = osddisksizei * 1000;
						v.customize [ "createhd", "--filename", "disk_osd-#{node[:hostname]}", "--size", "#{osddisksizea}" ]
						v.customize [ "storageattach", :id, "--storagectl", "IDE", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "disk_osd-#{node[:hostname]}.vdi" ]
					end
				end
			end
			if node[:hostname] == "bootstrap"
				node_config.vm.provision "bootstrap_cephadm", after: "init2", type: "shell", path: "scripts/setup_cephadm_bootstrap.sh"												   
			end
		end
		config.hostmanager.enabled = true
		config.hostmanager.manage_host = false
		config.hostmanager.manage_guest = true
		#config.hostmanager.ignore_private_ip = false
		#config.hostmanager.include_offline = true
		if Vagrant.has_plugin?("HostManager")
			config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
				read_ip_address(vm)									
			end
		end
	end
end