require 'spec_helper'

class MaterializedClient < ActiveRecord::Base
end

class UnmaterializedClient < ActiveRecord::Base
end

describe MaterializedClient do
  describe 'Stays up to date' do
    describe 'Relative to its unmaterialized version' do
      specify 'On insertions, updates, and deletions' do
        unm_client = UnmaterializedClient.create(name: 'new client')
        mat_client = MaterializedClient.find_by(name: 'new client')

        UnmaterializedClient.count.should == 1
        MaterializedClient.count.should == 1

        MaterializedClient.first.name.should == 'new client'
        UnmaterializedClient.first.name.should == 'new client'


      end
    end
  end
end
