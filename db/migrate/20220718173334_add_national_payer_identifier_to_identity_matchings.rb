class AddNationalPayerIdentifierToIdentityMatchings < ActiveRecord::Migration[7.0]
  def change
    add_column :identity_matchings, :national_insurance_payer_identifier, :string
  end
end
