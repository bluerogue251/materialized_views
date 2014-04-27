class CreateUnmaterializedClients < ActiveRecord::Migration
  def change
    create_table :unmaterialized_clients do |t|
      t.string :name
    end
  end
end
