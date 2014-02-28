mssqlserver_restore_database node['description'] do
  file_path node['file_path']
  database node['database']
  script_path node['script_path']
  action :script
end