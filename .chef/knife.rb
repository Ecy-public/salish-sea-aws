log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/vagrant/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef-server/chef-validator.pem'
chef_server_url          'https://mgmt/organizations/ecology'
syntax_check_cache_path  '/vagrant/.chef/syntax_check_cache'
cookbook_path [ '/vagrant/cookbooks' ]
