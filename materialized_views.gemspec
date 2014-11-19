Gem::Specification.new do |spec|
  spec.name          = "materialized_views"
  spec.version       = '0.0.0'
  spec.date          = '2014-11-18'
  spec.summary       = 'Create auto-updating materialized views with ActiveRecord::Migration'
  spec.description   = 'Create auto-updating materialized views with ActiveRecord::Migration'
  spec.authors       = ["Teddy Widom"]
  spec.email         = ["theodore.widom@gmail.com"]
  spec.files         = ["lib/materialized_views.rb"]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_development_dependency "active_record_migrations"
  spec.add_development_dependency "pg"
end
