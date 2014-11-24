class CreateClientContactAssignments < ActiveRecord::Migration
  def change
    create_table :client_contact_assignments do |t|
      t.integer :client_id
      t.integer :contact_id
    end
  end
end
