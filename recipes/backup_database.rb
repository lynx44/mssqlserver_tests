mssqlserver_backup_database node['description'] do
  destination node['destination']
  database node['database']
  action :run
end