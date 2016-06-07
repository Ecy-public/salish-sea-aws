# -*- mode: ruby -*-
# vi: set ft=ruby :

cluster = ENV['ECOLOGY_CLUSTER_NAME']
cluster = 'a' unless cluster

Vagrant.configure(2) do |config|
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = ENV['AWS_KEY_ID']
    aws.secret_access_key = ENV['AWS_ACCESS_KEY']
    aws.session_token = ENV['AWS_SESSION_TOKEN']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.instance_type = "m3.medium"
    aws.ami = "ami-d2c924b2"
    aws.region = 'us-west-2'
    override.ssh.username = "centos"
    override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
    override.vm.box = "dummy"
  end
  config.vm.define "mgmt" do |mgmt|
    mgmt.vm.box = "bento/centos-7.2"
    mgmt.vm.network "private_network", ip: "192.168.33.254"
    mgmt.vm.hostname = "mgmt"
    mgmt.vm.provider :aws do |aws, override|
      aws.user_data = File.read("userdata.txt").gsub(/@@NODE@@/, 'mgmt')
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
    echo '172.31.33.15 mgmt.salishsea.wa.gov mgmt' >> /etc/hosts
    yum -y update
    yum -y install /vagrant/chef.rpm
    knife ssl fetch -s https://mgmt.salishsea.wa.gov/organizations/ecology
    mkdir -p /etc/chef
    cp -r /root/.chef/trusted_certs /etc/chef/
    cat /vagrant/clients/@@NODE@@.pem > /etc/chef/client.pem
    if knife node show -s https://mgmt.salishsea.wa.gov/organizations/ecology -u @@NODE@@ @@NODE@@ ; then
      knife node delete -s https://mgmt.salishsea.wa.gov/organizations/ecology --yes -u @@NODE@@ @@NODE@@
    fi
    knife node create -s https://mgmt.salishsea.wa.gov/organizations/ecology -u @@NODE@@ -d @@NODE@@
    chef-client -N @@NODE@@ -S https://mgmt.salishsea.wa.gov/organizations/ecology -r 'role[cluster-@@CLUSTER@@],recipe[ecology-cluster::@@RECIPE@@]'
  SHELL
  userdata = File.read("userdata.txt")
  config.vm.define "head-#{cluster}" do |head|
    head.vm.box = "bento/centos-7.2"
    head.vm.network "private_network", ip: "192.168.33.253"
    head.vm.hostname = "head-#{cluster}"
    head.vm.provider :aws do |aws, override|
      aws.user_data = File.read("userdata.txt").gsub(/@@NODE@@/, "head-#{cluster}")
      aws.block_device_mapping = [
        { 'DeviceName' => '/dev/sdb', 'Ebs.VolumeSize' => 1000 },
        { 'DeviceName' => '/dev/sdc', 'Ebs.VolumeSize' => 1000 },
        { 'DeviceName' => '/dev/sdd', 'Ebs.VolumeSize' => 1000 },
        { 'DeviceName' => '/dev/sde', 'Ebs.VolumeSize' => 1000 },
      ]
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
        aws.user_data = File.read("userdata.txt").gsub(/@@NODE@@/, "n#{x}-#{cluster}")
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
