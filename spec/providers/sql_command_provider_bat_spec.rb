require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../../../windows/libraries/helper')
require_relative('../../../mssqlserver/libraries/sqlcmd_helper')
require 'ostruct'

describe 'mssqlserver_tests::sql_command_provider_bat' do
  include Windows::Helper

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_sql_command']) do |node|
      node.set['description'] = 'restore db to script'
      node.set['script'] = 'c:\script.sql'
      node.set['username'] = 'user'
      node.set['password'] = 'password'
      node.set['database'] = 'the_database'
      node.set['instance'] = 'localhost'
      node.set['batch_path'] = 'c:\script.bat'
      node.set['mssqlserver']['sqlcmdpath'] = 'c:\sqlcmd.exe'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes expected values' do
    expect(converge).to bat_mssqlserver_sql_command(node['description']).with({
        :script => node['script'],
        :username => node['username'],
        :password => node['password'],
        :database => node['database'],
        :instance => node['instance'],
        :batch_path => node['batch_path']
    })
  end

  it 'creates script' do
    resource = OpenStruct.new
    resource.script = node['script']
    resource.username = node['username']
    resource.password = node['password']
    resource.database = node['database']
    resource.instance = node['instance']
    resource.batch_path = node['batch_path']
    helper = MSSqlServerCookbook::SqlCmdHelper.new(resource, node)
    shell_command = helper.create_shell_command(node['script'])

    expect(converge).to render_file(node['batch_path']).with_content(shell_command)
  end

  it 'converts path to windows friendly path' do
    node.set['batch_path'] = 'c:/some/thing'
    expect(converge).to render_file(win_friendly_path(node['batch_path']))
  end
end
