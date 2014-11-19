require 'spec_helper'

describe 'N-to-one table to materialized view mapping' do
  let!(:client)              { Client.create(name: 'Test client') }
  let!(:first_service)       { client.services.create(name: "first service" ) }
  let!(:second_service)      { client.services.create(name: "second service" ) }
  let(:materialized_client)  { MaterializedClient.find_by(id: client.id) }

  it 'Stays up to date after insert' do
    expect(materialized_client.service_names).to eq "first service, second service"
  end

  it 'Stays up to date after update' do
    first_service.update!(name: 'first service with new name')
    materialized_client.reload
    expect(materialized_client.service_names).to eq 'first service with new name, second service'

    second_service.update!(name: 'second service with a new name')
    materialized_client.reload
    expect(materialized_client.service_names).to eq 'first service with new name, second service with a new name'
  end

  it 'Stays up to date after destroy' do
    first_service.destroy!
    materialized_client.reload
    expect(materialized_client.service_names).to eq 'second service'

    second_service.destroy!
    materialized_client.reload
    expect(materialized_client.service_names).to be_nil
  end
end
