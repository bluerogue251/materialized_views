class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name
    end
  end
end
