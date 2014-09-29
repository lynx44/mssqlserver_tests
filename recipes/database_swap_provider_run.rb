mssqlserver_database_swap 'swap names' do
  source node['source_name']
  destination node['dest_name']
  action :run
end