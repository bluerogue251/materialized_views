class Client < ActiveRecord::Base
  has_many :services
  belongs_to :region
end

class Service < ActiveRecord::Base
end

class Region < ActiveRecord::Base
end

class Contact < ActiveRecord::Base
end

class ClientContactAssignment < ActiveRecord::Base
  belongs_to :client
  belongs_to :contact
end

class MaterializedClient < ActiveRecord::Base
end

