require 'materialized_views'

class CreateMaterializedClients < ActiveRecord::Migration
  def change
    materialize 'materialized_clients', <<-eos
      SELECT
        clients.id,
        clients.name,
        string_agg(services.name, ', ' ORDER BY services.name) as service_names
      FROM clients
        LEFT OUTER JOIN services ON clients.id = services.client_id
      GROUP BY clients.id
    eos
    create_refresh_row_function_for('materialized_clients', { primary_key: 'id' })

    create_1_to_1_refresh_triggers_for('materialized_clients', 'clients', 'id')

    # TODO this should really by 1 to n refresh triggers
    create_1_to_1_refresh_triggers_for('materialized_clients', 'services', 'client_id')

    execute "ALTER TABLE materialized_clients ADD PRIMARY KEY (id)"
  end
end
