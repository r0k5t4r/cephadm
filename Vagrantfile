#!/usr/bin/ruby
# Below you can define specific parameters for each individual VM to be deployed by Vagrant.
# ip = assign this static IP
# box = which vagrant box should be deployed
# osd = configure an additonal virtual disk
# osdsize = size of the additional virtual disk in GB
# the remaining parameters should be pretty much self explanatory :)

nodes = [
  { :hostname => 'osd1',  		:ip => '192.168.2.201', :box => 'centos/stream8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20' },
  { :hostname => 'osd2',  		:ip => '192.168.2.202', :box => 'centos/stream8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20' },
  { :hostname => 'osd3',  		:ip => '192.168.2.203', :box => 'centos/stream8', :cpus => 1, :ram => 1024, :osd => 'yes', :osdsize => '20' },
  { :hostname => 'bootstrap', 	:ip => '192.168.2.200', :box => 'centos/stream8' }, 
]

$logger = Log4r::Logger.new('vagrantfile')
#$logger.outputters = FileOutputter.new('log_warn', :filename => "test_log4r_file.log", :level => INFO )
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

  # the second inet is more accurate
  result.chomp
end

Vagrant.configure("2") do |config|
  
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig| 
	  nodeconfig.vm.box = node[:box]
      nodeconfig.vm.hostname = node[:hostname]
      nodeconfig.vm.network 'public_network', ip: node[:ip], netmask: '255.255.255.0'
	  
	  # this script is no longer required since there is now a centos 8 stream vagrant box available
	  #nodeconfig.vm.provision "init0", type: "shell", path: "scripts/convert_to_centos_stream.sh"
	  # ******************************* THE FOLLOWING SCRIPTS ARE MANDATORY *************************************
	  # enable root access via ssh, root password will be set to cephadm123, you can change this in the script
	  nodeconfig.vm.provision "init1", before: "init2", type: "shell", path: "scripts/setup_ssh_root_access.sh"
	  # disable IPv6	
	  nodeconfig.vm.provision "init2", type: "shell", path: "scripts/disable_ipv6.sh"
	  # disable SELinux
	  nodeconfig.vm.provision "init3", type: "shell", path: "scripts/disable_selinux.sh"
	  # *********************************************************************************************************

	  # here we declare variables to use the values defined above in the nodes section, in case no values are defined, we set a default value
      memory = node[:ram] ? node[:ram] : 512;
	  osddisksize = node[:osdsize] ? node[:osdsize] : 10;
	  vcpus = node[:cpus] ? node[:cpus] : 1;
	  
	  nodeconfig.vm.provider :virtualbox do |vb|
	    vb.name = node[:hostname]
	    # here we customize our virtual box vm using the values from the variables
		vb.customize ["modifyvm", :id, "--memory", memory.to_s]
		vb.customize ["modifyvm", :id, "--cpus", vcpus.to_s]
		
        if node[:osd] == "yes"
		  # If osd is set to 'yes' then add an additional virtual disk to IDE controller on port 1 device 0
		  # In case you use different Vagrant Boxes, and you receive an error like Stderr: VBoxManage: error: Could not find a controller named 'IDE', this is caused by the fact that the Vagrant Box uses a different type of disk controller.
		  # You can lookup the correct name and settings of the controller using the following vboxmanage commands
		  # Show all VMs
		  # VBoxManage list vms
		  # Show the Storage of a particular VM
		  # vboxmanage showvminfo 40aa7691-a75f-4e5a-99fb-135fc0295858 | findstr Storage
		  osddisksizei = osddisksize.to_i
		  osddisksizea = osddisksizei * 1000;
		  vb.customize [ "createhd", "--filename", "disk_osd-#{node[:hostname]}", "--size", "#{osddisksizea}" ]
		  vb.customize [ "storageattach", :id, "--storagectl", "IDE", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "disk_osd-#{node[:hostname]}.vdi" ]
        end
		
	  end
	  
	  if node[:hostname] == "bootstrap"
			#nodeconfig.vm.provision "bootstrap_cephadm", after: "init2", type: "shell", path: "scripts/setup_cephadm_bootstrap.sh"
	  end
	  
    end
    config.hostmanager.enabled = true
    config.hostmanager.manage_guest = true
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