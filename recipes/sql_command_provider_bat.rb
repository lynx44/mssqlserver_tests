mssqlserver_sql_command node['description'] do
  script node['script']
  username node['username']
  password node['password']
  database node['database']
  instance node['instance']
  batch_path node['batch_path']
  action :bat
end