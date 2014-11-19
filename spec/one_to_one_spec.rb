require 'spec_helper'

describe 'One-to-one table to materialized view mapping' do
  let(:client_name)          { 'test client name' }
  let!(:client)              { Client.create(name: client_name) }
  let(:materialized_client)  { MaterializedClient.find_by(id: client.id) }

  it 'Stays up to date after insert' do
    expect(Client.count).to eq 1
    expect(MaterializedClient.count).to eq 1
    expect(materialized_client.name).to eq client_name
  end

  it 'Stays up to date after update' do
    client.update!(name: 'new test client name')
    expect(materialized_client.name).to eq 'new test client name'
  end

  it 'Stays up to date after destroy' do
    expect(Client.count).to eq 1
    expect(MaterializedClient.count).to eq 1

    client.destroy!

    expect(Client.count).to eq 0
    expect(MaterializedClient.count).to eq 0
  end
end
