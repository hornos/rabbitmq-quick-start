cluster=search( :clusters, "id:cluster" )[0]
# Create the munge key from template
template "/etc/hosts" do
  source "hosts.erb"
  owner "root"
  mode "0644"
  variables({:cluster=>cluster})
end
