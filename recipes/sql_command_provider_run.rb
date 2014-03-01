mssqlserver_sql_command node['description'] do
  command node['sql_command']
  username node['username']
  password node['password']
  database node['database']
  instance node['instance']
  action :run
end