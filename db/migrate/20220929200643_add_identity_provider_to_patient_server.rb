class AddIdentityProviderToPatientServer < ActiveRecord::Migration[7.0]
  def change
    add_column :patient_servers, :identity_provider, :string
  end
end
