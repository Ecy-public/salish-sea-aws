# -*- mode: ruby -*-
# vi: set ft=ruby :

cluster = ENV['ECOLOGY_CLUSTER_NAME']
cluster = 'a' unless cluster

Vagrant.configure(2) do |config|
  config.vm.define "mgmt" do |mgmt|
    mgmt.vm.box = "bento/centos-7.2"
    mgmt.vm.network "private_network", ip: "192.168.33.254"
    mgmt.vm.hostname = "mgmt"
    mgmt.vm.provider :aws do |aws, override|
      aws.access_key_id = ENV['AWS_KEY_ID']
      aws.secret_access_key = ENV['AWS_ACCESS_KEY']
      aws.session_token = ENV['AWS_SESSION_TOKEN']
      aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
      aws.instance_type = "m3.medium"
      aws.ami = "ami-d2c924b2"
      aws.region = 'us-west-2'
      aws.user_data = File.read("mgmtuserdata.txt")
      override.ssh.username = "centos"
      override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
      override.vm.box = "dummy"
    end
    mgmt.vm.provider :libvirt do |libvirt|
      libvirt.memory = '1024'
    end
    mgmt.vm.provider :virtualbox do |vb|
      vb.memory = '1024'
    end
    mgmt.vm.provision "shell", privileged: false, inline: <<-SHELL
      # need to install chef-server manually
      set -xe
      if ! test -e /vagrant/chef-server.rpm ; then
        echo Download the chef-server rpm and put it in /vagrant/chef-server.rpm
        exit -1
      fi

      sudo yum -y update
      sudo yum -y install /vagrant/chef-server.rpm /vagrant/vagrant.rpm /vagrant/chefdk.rpm vim nfs-server
      sudo chef-server-ctl reconfigure
      sudo chef-server-ctl user-create admin admin admin dmlb2000@gmail.com password --filename /vagrant/.chef/admin.pem
      sudo chef-server-ctl org-create ecology 'Ecology Organization' --filename /vagrant/.chef/chef-validator.pem
      sudo chef-server-ctl org-user-add ecology admin --admin
      export HOME=/vagrant
      cd ~
      knife ssl fetch
      mkdir -p /vagrant/clients
      for node in `seq 0 3` ; do
        knife client create n${node} -d > clients/n${node}.pem
      done
      knife client create head -d > clients/head.pem
      knife upload /
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
      knife node delete -s https://mgmt/organizations/ecology --yes -u @@NODE@@ @@NODE@@
    fi
    knife node create -s https://mgmt/organizations/ecology -u @@NODE@@ -d @@NODE@@
    chef-client -S https://mgmt/organizations/ecology -r 'role[cluster-@@CLUSTER@@],recipe[ecology-cluster::@@RECIPE@@]'
  SHELL

  config.vm.define "head-#{cluster}" do |head|
    head.vm.box = "bento/centos-7.2"
    head.vm.network "private_network", ip: "192.168.33.253"
    head.vm.hostname = "head-#{cluster}"
    head.vm.provider :aws do |aws, override|
      aws.access_key_id = ENV['AWS_KEY_ID']
      aws.secret_access_key = ENV['AWS_ACCESS_KEY']
      aws.session_token = ENV['AWS_SESSION_TOKEN']
      aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
      aws.instance_type = "c4.4xlarge"
      aws.ami = "ami-d2c924b2"
      aws.region = 'us-west-2'
      aws.user_data = File.read("userdata.txt")
      override.ssh.username = "centos"
      override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
      override.vm.box = "dummy"
    end
    head.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
    head.vm.provider :libvirt do |libvirt|
      libvirt.memory = '1024'
    end
    head.vm.provision "shell", inline: shell_script.gsub(/@@NODE@@/, "head-#{cluster}")\
                                                   .gsub(/@@CLUSTER@@/, cluster)\
                                                   .gsub(/@@RECIPE@@/, 'head')
  end

  # this is a bit complicated but it produces array ["0", "1",..."3"]
  suffixes = (0..7).to_a
  suffixes.each do |x|
    config.vm.define "n#{x}-#{cluster}" do |node|
      node.vm.box = "bento/centos-7.2"
      node.vm.network "private_network", ip: "192.168.33.#{x+10}"
      node.vm.hostname = "n#{x}-#{cluster}"
      node.vm.provider :aws do |aws, override|
        aws.access_key_id = ENV['AWS_KEY_ID']
        aws.secret_access_key = ENV['AWS_ACCESS_KEY']
        aws.session_token = ENV['AWS_SESSION_TOKEN']
        aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
        aws.instance_type = "c4.4xlarge"
        aws.ami = "ami-d2c924b2"
        aws.region = 'us-west-2'
        aws.user_data = File.read("userdata.txt")
        override.ssh.username = "centos"
        override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
        override.vm.box = "dummy"
      end
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      node.vm.provider :libvirt do |libvirt|
        libvirt.memory = '1024'
      end
      node.vm.provision "shell", inline: shell_script.gsub(/@@NODE@@/, "n#{x}-#{cluster}")\
                                                     .gsub(/@@CLUSTER@@/, cluster)\
                                                     .gsub(/@@RECIPE@@/, 'compute')
    end
  end
end
