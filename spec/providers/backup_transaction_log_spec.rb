require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::backup_transaction_log' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_backup_transaction_log']) do |node|
      node.set['description'] = 'default description'
      node.set['destination'] = 'c:\trx.trn'
      node.set['database'] = 'db'
    end
  end
  let(:converge) { chef_run.converge(described_recipe) }
  let(:node) { chef_run.node }

  it 'passes expected values' do
    expect(converge).to run_mssqlserver_backup_transaction_log(node['description']).with({
        :destination => node['destination'],
        :database => node['database']
     })
  end

  it 'runs transaction log command' do
    expect(converge).to run_mssqlserver_sql_command(node['description']).with({
        :database => 'master',
        :command => "BACKUP LOG [#{node['database']}] TO  DISK = N'#{node['destination']}' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION, STATS = 5
    GO"
    })
  end

  it 'runs transaction log command WITH options' do
    node.set['with'] = ['COPYONLY']
    expect(converge).to run_mssqlserver_sql_command(node['description']).with({
        :database => 'master',
        :command => "BACKUP LOG [#{node['database']}] TO  DISK = N'#{node['destination']}' WITH COPYONLY
    GO"
    })
  end
end
