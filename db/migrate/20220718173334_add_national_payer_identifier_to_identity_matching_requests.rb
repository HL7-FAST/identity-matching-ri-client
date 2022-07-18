class AddNationalPayerIdentifierToIdentityMatchingRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :identity_matching_requests, :national_insurance_payer_identifier, :string
  end
end
