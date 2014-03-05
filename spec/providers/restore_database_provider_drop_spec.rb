require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::restore_database_provider_drop' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_restore_database']) do |node|
      node.set['description'] = 'restore db'
      node.set['file_path'] = 'c:\backup.bak'
      node.set['username'] = 'user'
      node.set['password'] = 'password'
      node.set['database'] = 'somedb'
      node.set['instance'] = 'some.server.net'
      node.set['data_directory'] = 'c:\data'
      node.set['log_directory'] = 'c:\logs'
      node.set['with'] = ['RECOVERY']
      node.set['timeout'] = 100
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes expected values' do
    expect(converge).to drop_mssqlserver_restore_database(node['description']).with({
        :username => node['username'],
        :password => node['password'],
        :database => node['database'],
        :instance => node['instance'],
        :timeout => node['timeout']
    })
  end

  it 'runs drop command on specified database' do
    expect(converge).to run_mssqlserver_sql_command("drop database #{node['database']}").with({
        :command =>
"IF EXISTS(SELECT name FROM sys.databases WHERE name='#{node['database']}')
BEGIN
	DROP DATABASE [#{node['database']}]
END",
        :instance => node['instance'],
        :database => 'master'
    })
  end
end
