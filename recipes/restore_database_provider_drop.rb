mssqlserver_restore_database node['description'] do
  username node['username']
  password node['password']
  database node['database']
  instance node['instance']
  timeout node['timeout']
  action :drop
end