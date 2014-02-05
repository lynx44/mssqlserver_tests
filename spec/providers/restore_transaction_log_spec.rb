require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::restore_transaction_log' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_restore_transaction_log']) do |node|
      node.set['description'] = 'default description'
      node.set['source'] = 'c:\trx.trn'
      node.set['database'] = 'db'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes expected values' do
    expect(converge).to run_mssqlserver_restore_transaction_log(node['description']).with({
         :source => node['source'],
         :database => node['database']
     })
  end

  it 'runs default transaction log command' do
    expect(converge).to run_mssqlserver_sql_command(node['description']).with({
        :database => 'master',
        :command => "RESTORE LOG [#{node['database']}] FROM  DISK = N'#{node['source']}' WITH NOUNLOAD, STATS = 5
    GO"
    })
  end

  it 'runs transaction log command WITH options' do
    node.set['with'] = ['NORECOVERY']
    expect(converge).to run_mssqlserver_sql_command(node['description']).with({
          :database => 'master',
          :command => "RESTORE LOG [#{node['database']}] FROM  DISK = N'#{node['source']}' WITH NORECOVERY
    GO"
      })
  end
end
