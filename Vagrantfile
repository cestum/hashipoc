Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.synced_folder "files", "/vagrant"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 4646, host: 4646

  config.vm.provision "base",            type: "shell", path: "files/base.sh"
  config.vm.provision "consul",          type: "shell", path: "files/consul.sh"
  config.vm.provision "haproxy",         type: "shell", path: "files/haproxy.sh"
  config.vm.provision "consul-template", type: "shell", path: "files/consul-template.sh"
  config.vm.provision "dnsmasq",         type: "shell", path: "files/dnsmasq.sh"
  config.vm.provision "vault",           type: "shell", path: "files/vault.sh"
  config.vm.provision "nomad",           type: "shell", path: "files/nomad.sh"
  config.vm.provision "vault-nomad",     type: "shell", path: "files/vault-nomad.sh"
  config.vm.provision "hashi-ui",        type: "shell", path: "files/hashi-ui.sh"
  config.vm.provision "app",             type: "shell", path: "files/application.sh"
end
