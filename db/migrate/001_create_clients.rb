class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
    end
  end
end
