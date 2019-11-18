
Vagrant.configure(2) do |config|

  config.vm.define "node1" do |node1|
    node1.vm.network :private_network, ip: "192.168.50.150"
    node1.vm.box = "bento/ubuntu-16.04"
    node1.vm.hostname = "node1"
    node1.vm.network "private_network", type: "dhcp"
    
    node1.vm.network "forwarded_port", guest: 3000, host: 3000
    node1.vm.network :forwarded_port, guest: 3646, host: 3646, auto_correct: true
    node1.vm.network :forwarded_port, guest: 3200, host: 3200, auto_correct: true
    node1.vm.network :forwarded_port, guest: 3500, host: 3500, auto_correct: true

    node1.vm.network :forwarded_port, guest: 8500, host: 8500, auto_correct: true
    node1.vm.network :forwarded_port, guest: 4646, host: 4646, auto_correct: true
    node1.vm.network :forwarded_port, guest: 9998, host: 9998, auto_correct: true
    node1.vm.network :forwarded_port, guest: 9999, host: 9999, auto_correct: true

    node1.vm.network :forwarded_port, guest: 8888, host: 8888, auto_correct: true
    node1.vm.network :forwarded_port, guest: 8008, host: 8008, auto_correct: true
    node1.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
    node1.vm.network :forwarded_port, guest: 8081, host: 8081, auto_correct: true
    node1.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct: true
    node1.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct: true
    node1.vm.network :forwarded_port, guest: 6379, host: 6379, auto_correct: true

    node1.vm.provision "check vault and start nomad", type: "shell", inline: "sudo supervisorctl start consul-template-vault"
    #config.vm.provision "app", type: "shell", path: "files/app/application.sh"
    node1.vm.post_up_message = "
    Nomad has been provisioned and is available at the following web address:
    http://localhost:4646/ui/     <<----  Primary Nomad UI (node1)
    Nomad has Consul installed as well with web UI available at the following web address:
    http://localhost:8500/ui/     <<----  Primary Consul UI (node1)
    Primary Vault node has been provisioned and is available at the following web address:
    http://localhost:8200/ui/     <<----  Primary Vault UI (node3)
    Nomad node2 has been provisioned and is available at the following web address:
    http://localhost:5646/ui/     <<----  Nomad UI (node2)
    Nomad node3 has been provisioned and is available at the following web address:
    http://localhost:6646/ui/     <<----  Nomad UI (node3)"
  end

  
  config.vm.define "node2" do |node2|
    node2.vm.network :private_network, ip: "192.168.50.151"
    node2.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
    node2.vm.hostname = "node2"
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.network :forwarded_port, guest: 8500, host: 8501, auto_correct: true
    node2.vm.network :forwarded_port, guest: 8200, host: 8201, auto_correct: true
    node2.vm.network :forwarded_port, guest: 4646, host: 5646, auto_correct: true

    node2.vm.network :forwarded_port, guest: 8888, host: 8888, auto_correct: true
    node2.vm.network :forwarded_port, guest: 8008, host: 8008, auto_correct: true
    node2.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
    node2.vm.network :forwarded_port, guest: 8081, host: 8081, auto_correct: true
    node2.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct: true
    node2.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct: true
    node2.vm.network :forwarded_port, guest: 6379, host: 6379, auto_correct: true

    node2.vm.provision "check vault and start nomad", type: "shell", inline: "sudo supervisorctl start consul-template-vault"
  end

  config.vm.define "node3" do |node3|
    node3.vm.network :private_network, ip: "192.168.50.152"
    node3.vm.box = "bento/ubuntu-16.04" # 16.04 LTS
    node3.vm.hostname = "node3"
    node3.vm.network "private_network", type: "dhcp"
    
    node3.vm.network :forwarded_port, guest: 8200, host: 8200, auto_correct: true
    node3.vm.network :forwarded_port, guest: 8500, host: 8502, auto_correct: true
    node3.vm.network :forwarded_port, guest: 8200, host: 8200, auto_correct: true
    node3.vm.network :forwarded_port, guest: 4646, host: 6646, auto_correct: true

    node3.vm.network :forwarded_port, guest: 8888, host: 8888, auto_correct: true
    node3.vm.network :forwarded_port, guest: 8008, host: 8008, auto_correct: true
    node3.vm.network :forwarded_port, guest: 8080, host: 8080, auto_correct: true
    node3.vm.network :forwarded_port, guest: 8081, host: 8081, auto_correct: true
    node3.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct: true
    node3.vm.network :forwarded_port, guest: 9200, host: 9200, auto_correct: true
    node3.vm.network :forwarded_port, guest: 6379, host: 6379, auto_correct: true
    ### Start Vault on Node3
    node3.vm.provision "mysql", type: "shell", path: "files/mysql/setup.sh"
    node3.vm.provision "start vault", type: "shell", inline: "sudo supervisorctl restart vault"
    node3.vm.provision "shell", path: "files/vault/vault-unseal.sh",
      privileged: true,
      env: {"PATH" => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"}
    node3.vm.provision "shell", path: "files/vault/vault-nomad.sh",
      privileged: true,
      env: {"PATH" => "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"}
    #node3.vm.provision "restart nomad", type: "shell", inline: "sudo supervisorctl restart nomad"
  end

  config.vm.synced_folder "files", "/vagrant"
  config.vm.provision "base",            type: "shell", path: "files/base.sh"
  config.vm.provision "go",              type: "shell", path: "files/go.sh"
  config.vm.provision "cfssl",           type: "shell", path: "files/security/cfssl.sh"
  config.vm.provision "consul",          type: "shell", path: "files/consul/consul.sh"
  config.vm.provision "consul-online",   type: "shell", path: "files/consul-online/consul-online.sh"
  config.vm.provision "haproxy",         type: "shell", path: "files/haproxy.sh"
  config.vm.provision "dnsmasq",         type: "shell", path: "files/dnsmasq/dnsmasq.sh"
  config.vm.provision "vault",           type: "shell", path: "files/vault/vault.sh"
  config.vm.provision "nomad",           type: "shell", path: "files/nomad/nomad.sh"

  config.vm.provision "start consul", type: "shell", inline: "sudo supervisorctl start consul"
  #wait for consul leader script
  config.vm.provision "start consul-online", type: "shell", inline: "sudo supervisorctl start consul-online"
  #wait for vault to be ready
  config.vm.provision "start nomad", type: "shell", inline: "sudo supervisorctl start vault-ready"
  
  config.vm.provision "consul-template", type: "shell", path: "files/consul/consul-template.sh"

  # Increase memory for Parallels Desktop
  config.vm.provider "parallels" do |p|
    p.memory = 4096
    p.cpus = 3
  end

  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
        vb.cpus = "2"
        vb.memory = "4096"
  end

  # Increase memory for VMware
  ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = "4096"
    end
  end
end
