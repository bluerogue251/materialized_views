require 'spec_helper'

describe 'One-to-n table to materialized view mapping with a middle table (join table) in between' do
  let(:first_contact)  { Contact.create!(name: 'first contact') }
  let(:second_contact) { Contact.create!(name: 'second contact') }
  let(:third_contact)  { Contact.create!(name: 'third contact') }

  let(:client)  { Client.create! }

  let(:first_assignment) { ClientContactAssignment.create(client: client, contact: first_contact) }
  let(:second_assignment) { ClientContactAssignment.create(client: client, contact: second_contact) }

  let(:first_materialized_client)  { MaterializedClient.find_by(id: client.id) }
  let(:second_materialized_client) { MaterializedClient.find_by(id: second_client.id) }

  it 'Stays up to date after create of middle table' do
    first_assignment; second_assignment
    expect(first_materialized_client.contact_names).to eq 'first contact, second contact'
  end

  it 'Stays up to date after update of middle table' do
    first_assignment; second_assignment
    first_assignment.update!(contact: third_contact)
    expect(first_materialized_client.contact_names).to eq 'second contact, third contact'
  end

  it 'Stays up to date after update of origin table' do
    first_assignment; second_assignment
    first_contact.update!(name: 'new first contact name')
    expect(first_materialized_client.contact_names).to eq 'new first contact name, second contact'
  end
end
