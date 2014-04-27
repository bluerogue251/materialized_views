require 'spec_helper'

class MaterializedClient < ActiveRecord::Base
end

class UnmaterializedClient < ActiveRecord::Base
end

describe MaterializedClient do
  describe 'Stays up to date relative its unmaterialized parent' do
    specify 'On insertions' do
      UnmaterializedClient.create(name: 'new client')
      UnmaterializedClient.count.should == 1
      MaterializedClient.count.should == 1
    end
  end
end
