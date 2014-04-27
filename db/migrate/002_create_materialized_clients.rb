class CreateMaterializedClients < ActiveRecord::Migration
  def change
    create_table :materialized_clients do |t|
      t.string :name
    end
  end
end
