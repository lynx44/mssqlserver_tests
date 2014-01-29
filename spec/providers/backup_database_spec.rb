require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::backup_database' do
  description = 'default description'
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_backup_database']) do |node|
      node.set['description'] = description
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

  it 'runs action' do
    expected_description = 'test'
    node.set['description'] = expected_description

    expect(converge).to run_mssqlserver_backup_database(expected_description)
  end

  it 'passes destination parameter' do
    expected = 'c:\test\test.bak'
    node.set['destination'] = expected

    expect(converge).to run_mssqlserver_backup_database(description).with({ :destination => expected })
  end

  it 'passes database parameter' do
    expected = 'test_database'
    node.set['database'] = expected

    expect(converge).to run_mssqlserver_backup_database(description).with({ :database => expected })
  end

  it 'runs backup script on node' do
    database = 'test_database'
    destination = 'c:\test\test.bak'

    node.set['database'] = database
    node.set['destination'] = destination
    expected = "BACKUP DATABASE [#{database}] TO  DISK = N'#{destination}' WITH NOFORMAT, INIT,  NAME = N'#{database}-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
    GO"

    expect(converge).to run_mssqlserver_sql_command('run backup script').with({ :database => 'master', :command => expected })
  end
end