# Create the munge key from template
template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  mode "0644"
end

puts node[:cluster].inspect


