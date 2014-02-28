require 'chefspec'
require_relative('../../../../chefspec/config')
require_relative('../../../../chefspec_extensions/automatic_resource_matcher')

describe 'mssqlserver_tests::restore_database_provider_script' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['mssqlserver_restore_database']) do |node|
      node.set['description'] = 'restore db to script'
      node.set['file_path'] = 'c:\backup.bak'
      node.set['database'] = 'somedb'
      node.set['script_path'] = 'c:\restore_script.sql'
    end
  end

  let(:converge) do
    chef_run.converge(described_recipe)
  end

  let(:node) do
    chef_run.node
  end

  it 'passes expected values' do
    expect(converge).to script_mssqlserver_restore_database(node['description']).with({
        :file_path => node['file_path'],
        :database => node['database'],
        :script_path => node['script_path']
    })
  end

  it 'creates script' do
    expect(converge).to render_file(node['script_path']).with_content(/USE MASTER/)
  end
end
