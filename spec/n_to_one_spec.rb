require 'spec_helper'

describe 'N-to-one table to materialized view mapping' do
  let!(:client)              { Client.create(name: 'Test client') }
  let(:materialized_client)  { MaterializedClient.find_by(id: client.id) }

  it 'Stays up to date after insert' do
    expect(materialized_client.service_names).to be_null

    Service.create(client: client, name: 'service 1')
    materialized_client.reload
    expect(materialized_client.service_names).to eq 'service 1'

    Service.create(client: client, name: 'service 2')
    materialized_client.reload
    expect(materialized_client.service_names).to eq 'service 1, service 2'
  end

  it 'Stays up to date after update' do
    first_service  = Service.create(name: 'first service')
    second_service = Service.create(name: 'second service')
    expect(materialized_client.service_names).to eq 'first_service, second service'

    first_service.update!(name: 'first service with new name')
    expect(materialized_client.service_names).to eq 'first service with new name, second service'

    second_service.update!(name: 'second service with a new name')
    expect(materialized_client.service_names).to eq 'first service with new name, second service with a new name'
  end

  it 'Stays up to date after destroy' do
    first_service  = Service.create(name: 'first service')
    second_service = Service.create(name: 'second service')
    expect(materialized_client.service_names).to eq 'first_service, second service'

    first_service.delete!
    expect(materialized_client.service_names).to eq 'second service'

    second_service.delete!
    expect(materialized_client.service_names).to be_nil
  end
end
