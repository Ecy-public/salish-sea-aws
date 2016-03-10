#!/bin/bash -e

wget -O vagrant.rpm https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm
wget -O chefdk.rpm https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/chefdk-0.11.0-1.el7.x86_64.rpm
wget -O chef.rpm https://opscode-omnibus-packages.s3.amazonaws.com/el/7/x86_64/chef-12.7.2-1.el7.x86_64.rpm
wget -O slurm.tar.bz2 http://www.schedmd.com/download/latest/slurm-15.08.8.tar.bz2

echo "
Chef Server requires a click through agreement so please go to the chef server
url for RHEL 6 version 12.4.1 (https://downloads.chef.io/chef-server/redhat/)
and download the rpm and copy it to chef-server.rpm in this directory.
"
