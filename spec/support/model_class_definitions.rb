class Client < ActiveRecord::Base
  has_many :services
  belongs_to :region
end

class Service < ActiveRecord::Base
end

class Region < ActiveRecord::Base
end

class MaterializedClient < ActiveRecord::Base
end

