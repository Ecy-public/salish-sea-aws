# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "mgmt" do |mgmt|
    mgmt.vm.box = "opscode-centos-7.2"
    mgmt.vm.network "private_network", ip: "192.168.33.254"
    mgmt.vm.hostname = "mgmt"
    mgmt.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    mgmt.vm.provision "shell", inline: <<-SHELL
      # need to install chef-server manually
      set -xe
      if ! test -e /vagrant/chef-server.rpm ; then
        echo Download the chef-server rpm and put it in /vagrant/chef-server.rpm
        exit -1
      fi

      yum -y update
      yum -y install /vagrant/chef-server.rpm /vagrant/vagrant.rpm /vagrant/chefdk.rpm
      chef-server-ctl reconfigure
      chef-server-ctl user-create admin admin admin dmlb2000@gmail.com password --filename /vagrant/.chef/admin.pem
      chef-server-ctl org-create ecology 'Ecology Organization' --filename /vagrant/.chef/chef-validator.pem
      chef-server-ctl org-user-add ecology admin --admin
      su - vagrant -c 'cd /vagrant; knife ssl fetch'
      su - vagrant -c 'mkdir -p /vagrant/clients'
      for node in `seq 0 3` ; do
        su - vagrant -c 'cd /vagrant; knife client create n'${node}' -d > clients/n'${node}'.pem'
      done
      su - vagrant -c 'cd /vagrant; knife client create head -d > clients/head.pem'
    SHELL
  end

  shell_script = <<-SHELL
    set -xe
    echo '192.168.33.254 mgmt' >> /etc/hosts
    yum -y update
    yum -y install /vagrant/chef.rpm
    knife ssl fetch -s https://mgmt/organizations/ecology
    mkdir -p /etc/chef
    cp -r /root/.chef/trusted_certs /etc/chef/
    cat /vagrant/clients/@@NODE@@.pem > /etc/chef/client.pem
    if knife node show -s https://mgmt/organizations/ecology -u @@NODE@@ @@NODE@@ ; then
      knife node delete -s https://mgmt/organizations/ecology -u @@NODE@@ @@NODE@@
    fi
    knife node create -s https://mgmt/organizations/ecology -u @@NODE@@ -d @@NODE@@
    chef-client -S https://mgmt/organizations/ecology
  SHELL

  config.vm.define "head" do |head|
    head.vm.box = "opscode-centos-7.2"
    head.vm.network "private_network", ip: "192.168.33.253"
    head.vm.hostname = "head"
    head.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    head.vm.provision "shell", inline: shell_script.gsub(/@@NODE@@/, "head")
  end

  # this is a bit complicated but it produces array ["0", "1",..."3"]
  suffixes = (0..3).to_a
  suffixes.each do |x|
    config.vm.define "n#{x}" do |node|
      node.vm.box = "opscode-centos-7.2"
      node.vm.network "private_network", ip: "192.168.33.#{x+1}"
      node.vm.hostname = "n#{x}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      node.vm.provision "shell", inline: shell_script.gsub(/@@NODE@@/, "n#{x}")
    end
  end
end
