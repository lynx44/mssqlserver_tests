require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::dacpac_provider_run' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_dacpac']) do |node|
      node.set['description'] = 'default description'
      node.set['dacpac_path'] = 'c:\db.dacpac'
      node.set['server'] = 'server1'
      node.set['database'] = 'db'
      node.set['username'] = 'user1'
      node.set['password'] = 'pass1'
      node.set['sql_action'] = :publish
      node.set['variables'] = {}
      node.set['msssqlserver']['dacpath']['sqlpackagepath'] = 'c:\sql\sqlpackage.exe'
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  it 'passes expected values' do
    expect(converge).to run_mssqlserver_dacpac(node['description'])
                        .with({
                           :dacpac_path => node['dacpac_path'],
                           :server => node['server'],
                           :database => node['database'],
                           :username => node['username'],
                           :password => node['password'],
                           :sql_action => node['sql_action'],
                           :variables => node['variables']
                       })
  end

  it 'appends target server name' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/TargetServerName:\"#{node['server']}\".*/
     })
  end

  it 'appends target database name' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/TargetDatabaseName:\"#{node['database']}\".*/
     })
  end

  it 'appends source file' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/SourceFile:\"#{Regexp.escape(node['dacpac_path'])}\".*/
     })
  end

  it 'appends action' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/Action:\"#{node['sql_action'].to_s}\".*/
    })
  end

  it 'appends username' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/TargetUser:\"#{node['username'].to_s}\".*/
     })
  end

  it 'appends password' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])

    expect(converge).to run_windows_batch('dacpac command').with({
         :code => /#{sql_package}.*\/TargetPassword:\"#{node['password'].to_s}\".*/
     })
  end

  it 'appends variables' do
    sql_package = Regexp.escape(node['msssqlserver']['dacpath']['sqlpackagepath'])
    node.set['variables'] = { 'test1' => 'test1val', 'test2' => 'test2val' }
    variable_string = Regexp.escape('/Variables:"test1=test1val" /Variables:"test2=test2val"')

    expect(converge).to run_windows_batch('dacpac command').with({
      :code => /#{sql_package}.*#{variable_string}.*/
    })
  end
end
