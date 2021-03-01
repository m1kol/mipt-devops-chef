current_dir = File.dirname(__FILE__)
log_level               :info
log_location            STDOUT
node_name               'chef_admin'
client_key              "#{current_dir}/chef_admin.pem"
validation_client_name  'chef_workstation'
validation_key          "#{current_dir}/chef_org-validator.pem"
chef_server_url         'https://chef-server/organizations/chef_org'
cache_type              'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path           ["#{current_dir}/../cookbooks"]