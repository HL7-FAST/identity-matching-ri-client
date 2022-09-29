class AddClientIdToPatientServer < ActiveRecord::Migration[7.0]
  def change
    add_column :patient_servers, :client_id, :string
  end
end
