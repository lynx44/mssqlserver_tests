require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::restore_database_provider_run' do
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
    expect(converge).to run_mssqlserver_restore_database(node['description']).with({
        :file_path => node['file_path'],
        :username => node['username'],
        :password => node['password'],
        :database => node['database'],
        :instance => node['instance'],
        :data_directory => node['data_directory'],
        :log_directory => node['log_directory'],
        :with => node['with'],
        :timeout => node['timeout']
    })
  end
end
