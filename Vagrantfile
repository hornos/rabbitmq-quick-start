# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# load clusterfile

begin
  file = 'Clusterfile.yml'
  STDOUT.puts "DEBUG: file: #{file}" if DEBUG
  if (file.end_with?(".yml"))
    $cluster = YAML.load_file file
  elsif (file.end_with?(".json"))
    $cluster = JSON.parse(File.read(file))
  else
    STDERR.puts "ERROR: Unknown file type, please use a file ending with either '.json' or '.yml'."
    exit(-1)
  end
rescue JSON::ParserError => e
  STDERR.puts e.message
  STDERR.puts "ERROR: Parsing error in the infrastructure file provided."
  exit(-1)
rescue Exception
  STDERR.puts "ERROR: No infrastructure .json or .yml file provided."
  exit(-1)
end


Vagrant::Config.run do |config|


  # defaults
  vm_default = proc do |cfg|
    cfg.vm.box = "precise64-ruby-1.9.3-p194"
    cfg.vm.box_url = "https://dl.dropbox.com/u/14292474/vagrantboxes/precise64-ruby-1.9.3-p194.box"

    cfg.vm.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    cfg.vm.customize ["modifyvm", :id, "--memory", 256]

    # https://groups.google.com/forum/?fromgroups#!topic/vagrant-up/a2COzF4E0gc%5B1-25%5D
    # http://serverfault.com/questions/414517/vagrant-virtualbox-host-only-multiple-node-networking-issue
    # cfg.vm.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
  end


  chef_default = proc do |chef|
    # local, solo, opscode's
    chef.cookbooks_path = ["cookbooks", "../cookbooks.solo", "../cookbooks/chef-server"]
    chef.roles_path     = "roles"
    chef.data_bags_path = "data_bags"
  end


  # configure nodes
  $cluster[:nodes].each do |node,opts|
    puts "Cluster configurtion: #{node}"
    config.vm.define node.to_s do |cfg|
      # defaults
      vm_default[cfg]

      cfg.vm.customize ["modifyvm", :id, "--cpus", opts[:cpus]]

      cfg.vm.host_name = node.to_s
      # cfg.vm.base_mac = '080037E7B25D'

      if not opts[:hostonly].nil? then
        cfg.vm.network :hostonly, opts[:hostonly]
      end
      if not opts[:bridged].nil? then
        cfg.vm.network :bridged, opts[:bridged]
      end

      # forwarding
      if not opts[:forward].nil? then
        opts[:forward].each { |p| cfg.vm.forward_port p[0], p[1]}
      end

      # vb guest version check
      # cfg.vbguest.auto_update = false
      # cfg.vbguest.no_remote   = true


      # provision by chef solo
      if opts[:chef_client] then
        orgname = opts[:chef_client][:orgname]

        cfg.vm.provision :chef_client do |chef|
          if opts[:chef_client][:server_url].nil? then
            chef.chef_server_url = "https://api.opscode.com/organizations/#{orgname}"
          else
            chef.chef_server_url = opts[:chef_client][:server_url]
          end

          if opts[:chef_client][:validation_client_name].nil? then
            chef.validation_client_name = "#{orgname}-validator"
            chef.validation_key_path = ".chef/#{orgname}-validator.pem"
          else
            chef.validation_client_name = opts[:chef_client][:validation_client_name]
            chef.validation_key_path = ".chef/#{opts[:chef_client][:validation_client_name]}.pem"
          end

          chef.encrypted_data_bag_secret_key_path = ".chef/data_bag.key"
          chef.node_name = "#{node.to_s}"
          if not opts[:log_level].nil? then
            chef.log_level = opts[:log_level]
          end
          chef.environment = opts[:chef_client][:environment]

          if not opts[:chef_client][:roles].nil? then 
            chef.run_list = opts[:chef_client][:roles].split(",")
          end

          chef.json = {
            :cluster => $cluster
          }

        end # :chef_client
      else
        cfg.vm.provision :chef_solo do |chef|
          # chef_default[chef]
          chef.cookbooks_path = opts[:cookbooks_path].nil? ? "cookbooks" : opts[:cookbooks_path]

          # chef.environment = "_default"
          chef.log_level = :debug

          # process role string
          if not opts[:chef_solo][:roles].nil? then 
            chef.run_list = opts[:chef_solo][:roles].split(",")
          end

          # access from chef node[:]
          chef.json = {
            :cluster => $cluster,
            :host => opts,
            "chef_server" => opts[:chef_server]
          }
        end
      end # :chef_solo

    end # cfg
  end # nodes

end
