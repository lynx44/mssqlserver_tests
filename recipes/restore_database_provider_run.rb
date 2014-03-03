mssqlserver_restore_database node['description'] do
  file_path node['file_path']
  username node['username']
  password node['password']
  database node['database']
  instance node['instance']
  data_directory node['data_directory']
  log_directory node['log_directory']
  with node['with']
  timeout node['timeout']
  action :run
end