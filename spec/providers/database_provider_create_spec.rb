require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::database_provider_create' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_database']) do |node|
      node.set['description'] = 'restore db'
      node.set['database'] = 'somedb'
      node.set['instance'] = 'some.server.net'
      node.set['username'] = 'user'
      node.set['password'] = 'password'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes syntax checks' do
    expect(converge)
  end

  it 'passes expected values' do
    expect(converge).to create_mssqlserver_database(node['description']).with({
        :username => node['username'],
        :password => node['password'],
        :database => node['database'],
        :instance => node['instance']
    })
  end

  it 'executes create script' do
    sql_command = "IF NOT EXISTS(SELECT Name FROM sys.databases WHERE Name='#{node['database']}') BEGIN CREATE DATABASE [#{node['database']}] END"
    expect(converge).to run_mssqlserver_sql_command("create #{node['database']} database").with({
        :username => node['username'],
        :password => node['password'],
        :database => 'master',
        :instance => node['instance'],
        :command => sql_command
    })
  end
end
