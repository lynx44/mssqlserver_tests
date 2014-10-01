mssqlserver_database node['description'] do
  database node['database']
  instance node['instance']
  username node['username']
  password node['password']
  action :drop
end