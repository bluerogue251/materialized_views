class CreateMaterializedClients < ActiveRecord::Migration
  def change
    materialize 'materialized_clients', 'select * from unmaterialized_clients'
    # add_tsvector_to(MissionsDatatable)
    create_refresh_row_function_for('materialized_clients', 'id')
    create_1_to_1_refresh_triggers_for('materialized_clients', 'unmaterialized_clients', 'id')
    execute "alter table materialized_clients add primary key (id)"
  end
end
