require 'spec_helper'

class Client < ActiveRecord::Base
end

class MaterializedClient < ActiveRecord::Base
end

describe MaterializedClient do
  let(:client_name)         { 'test client name' }
  let!(:client)              { Client.create(name: client_name) }
  let(:materialized_client)  { MaterializedClient.find_by(id: client.id) }

  it 'Stays up to date after insert' do
    both_should_have_counts_of(1)
    materialized_client.name.should == client_name
  end

  it 'Stays up to date after update' do
    client.update!(name: 'new test client name')
    both_should_have_counts_of(1)
    materialized_client.name.should == 'new test client name'
  end

  def both_should_have_counts_of(count)
    Client.count.should == count
    MaterializedClient.count.should == count
  end
end
