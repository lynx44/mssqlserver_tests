require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::database_rename_provider_run' do
  default_description = 'rename'
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_database_rename']) do |node|
      node.set['source_name'] = 'source'
      node.set['dest_name'] = 'destination'
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
    expect(converge).to run_mssqlserver_database_rename(default_description)
                        .with({
                                  :source => node['source_name'],
                                  :destination => node['dest_name']
                              })
  end

  it 'kills all connections to source database' do
    expect(converge).to run_mssqlserver_sql_command("kill connections to #{node['source_name']}").with({
       :command =>
"DECLARE @KillCurrentConnectionsCommand NVARCHAR(MAX)
SET @KillCurrentConnectionsCommand = N''

SELECT @KillCurrentConnectionsCommand = @KillCurrentConnectionsCommand + N'Kill ' + Convert(varchar, SPId) + N';'
FROM MASTER..SysProcesses
WHERE DBId = DB_ID('#{node['source_name']}') AND SPId <> @@SPId
EXEC(@KillCurrentConnectionsCommand)",
       :database => 'master'                                                                                                                                   })
  end

  it 'renames source to destination name' do
    expect(converge).to run_mssqlserver_sql_command("rename #{node['source_name']} to #{node['dest_name']}").with({
       :command =>
"ALTER DATABASE #{node['source_name']}
Modify Name = #{node['dest_name']};",
      :database => 'master' })
  end
end
