mssqlserver_database_rename 'swap names' do
  source node['source_name']
  destination node['dest_name']
  action :swap
end