require 'spec_helper'

describe 'One-to-n table to materialized view mapping' do
  let!(:region)                    { Region.create(name: "North America") }
  let!(:first_client)              { Client.create(region: region) }
  let!(:second_client)             { Client.create(region: region) }
  let(:first_materialized_client)  { MaterializedClient.find_by(id: first_client.id) }
  let(:second_materialized_client) { MaterializedClient.find_by(id: second_client.id) }

  it 'Stays up to date after update' do
    expect(first_materialized_client.region_name).to eq "North America"
    expect(second_materialized_client.region_name).to eq "North America"

    region.update!(name: "Antarctica")

    first_materialized_client.reload
    second_materialized_client.reload

    expect(first_materialized_client.region_name).to eq "Antarctica"
    expect(second_materialized_client.region_name).to eq "Antarctica"
  end
end
