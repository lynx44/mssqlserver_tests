require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')
require_relative('../../../mssqlserver/libraries/sqlcmd_helper')
require 'ostruct'

describe 'mssqlserver_tests::sql_command_provider_run' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_sql_command']) do |node|
      node.set['description'] = 'restore db to script'
      node.set['sql_command'] = 'select * from table'
      node.set['username'] = 'user'
      node.set['password'] = 'password'
      node.set['database'] = 'the_database'
      node.set['instance'] = 'localhost'
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
    expect(converge).to run_mssqlserver_sql_command(node['description']).with({
        :command => node['sql_command'],
        :username => node['username'],
        :password => node['password'],
        :database => node['database'],
        :instance => node['instance']
    })
  end

  it 'creates script' do
    script_path = 'c:\temp_script.sql'
    tempfile = double()
    tempfile.stub(:puts).with(an_instance_of(String))
    tempfile.stub(:close)
    tempfile.stub(:path).and_return(script_path)
    Tempfile.stub(:open).and_return(tempfile)

    resource = OpenStruct.new
    resource.command = node['sql_command']
    resource.username = node['username']
    resource.password = node['password']
    resource.database = node['database']
    resource.instance = node['instance']
    helper = MSSqlServerCookbook::SqlCmdHelper.new(resource, node)
    shell_command = helper.create_shell_command(script_path)

    expect(converge).to run_execute('sqlcommand').with({
        :command => shell_command,
        :returns => [0],
        :timeout => node['timeout']
     })
  end
end
