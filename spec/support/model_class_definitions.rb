class Client < ActiveRecord::Base
  has_many :services
end

class Service < ActiveRecord::Base
end

class MaterializedClient < ActiveRecord::Base
end

