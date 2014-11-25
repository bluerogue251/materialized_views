require 'materialized_views'

class CreateMaterializedClients < ActiveRecord::Migration
  def change
    mv = MaterializedView.new
    mv.name = 'materialized_clients'
    mv.definition = <<-eos
                      SELECT
                        clients.id,
                        clients.name,
                        string_agg(services.name, ', ' ORDER BY services.name) as service_names,
                        regions.name as region_name,
                        string_agg(contacts.name, ', ' ORDER BY contacts.name) as contact_names
                      FROM clients
                        LEFT OUTER JOIN services ON clients.id = services.client_id
                        LEFT OUTER JOIN regions  ON regions.id = clients.region_id
                        LEFT OUTER JOIN client_contact_assignments  ON clients.id = client_contact_assignments.client_id
                        LEFT OUTER JOIN contacts ON contacts.id = client_contact_assignments.contact_id
                      GROUP BY clients.id, regions.id
                    eos

    execute mv.create_unmaterialized_version
    execute mv.create_materialized_version
    execute mv.create_refresh_row_function

    clients_to_clients_mv = OneToOne.new(target: 'materialized_clients', origin: 'clients', foreign_key: 'id')
    clients_to_clients_mv.all_definitions { |sql| execute sql }

    # TODO this should really by n to 1 refresh triggers
    services_to_clients_mv = OneToOne.new(target: 'materialized_clients', origin: 'services', foreign_key: 'client_id')
    services_to_clients_mv.all_definitions { |sql| execute sql }

    # TODO this parameter list is super confusing!
    create_1_to_n_refresh_triggers_for('materialized_clients', 'regions', 'clients', 'id', 'region_id', 'id')

    # One to n triggers passing through a middle table also seem to require 1-to-1 triggers for the middle
    # table to the target table
    ca_to_clients_mv = OneToOne.new(target: 'materialized_clients', origin: 'client_contact_assignments', foreign_key: 'client_id')
    ca_to_clients_mv.all_definitions { |sql| execute sql }

    create_1_to_n_refresh_triggers_for('materialized_clients', 'contacts', 'client_contact_assignments', 'client_id', 'contact_id', 'id')

    execute "ALTER TABLE materialized_clients ADD PRIMARY KEY (id)"
  end
end
