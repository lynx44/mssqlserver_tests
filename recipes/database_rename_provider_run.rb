mssqlserver_database_rename 'rename' do
  source node['source_name']
  destination node['dest_name']
  action :run
end