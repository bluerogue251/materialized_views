class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :client_id
      t.string :name
    end
  end
end
