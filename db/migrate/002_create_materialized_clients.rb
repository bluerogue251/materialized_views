class CreateMaterializedClients < ActiveRecord::Migration
  def change
    materialize 'materialized_clients', 'select * from clients'
    create_refresh_row_function_for('materialized_clients', { primary_key: 'id' })
    create_1_to_1_refresh_triggers_for('materialized_clients', 'clients', 'id')
  end
end
