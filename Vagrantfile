# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  #puppet module install puppetlabs-postgresql --modulepath /vagrant/modules

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise32"

config.vm.define "barman" do |barman|
    barman.vm.network :private_network, ip: "192.168.33.12"
    barman.vm.host_name = "barman"

    barman.vm.provision :puppet do |puppet|
       puppet.manifests_path = "manifests"
       puppet.manifest_file  = "base-barman.pp"
       puppet.module_path = "modules"
       puppet.options = "--verbose --debug"
    end
  end

  config.vm.define "postgres" do |postgres|
    postgres.vm.network :private_network, ip: "192.168.33.10"
    postgres.vm.network :forwarded_port, host: 5432, guest: 5432
    postgres.vm.host_name = "postgres"

    postgres.vm.provision :puppet do |puppet|
       puppet.manifests_path = "manifests"
       puppet.manifest_file  = "base-postgres.pp"
       puppet.module_path = "modules"
       puppet.options = "--verbose --debug"
    end
  end
  
end
