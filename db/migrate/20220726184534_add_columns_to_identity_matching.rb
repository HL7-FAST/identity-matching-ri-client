class AddColumnsToIdentityMatching < ActiveRecord::Migration[7.0]
  def change
	# identifiers
    rename_column :identity_matchings, :national_insurance_payer_identifier, :national_insurance_payor_identifier
    add_column :identity_matchings, :passport_number, :string
    add_column :identity_matchings, :state_id_number, :string
	
	# more attributes in IDI Patient Profile
	add_column :identity_matchings, :language, :string

	# misc attributes for implementation
    add_column :identity_matchings, :request_json, :text
    add_column :identity_matchings, :weight, :integer
    add_column :identity_matchings, :idi_level, :integer
    add_column :identity_matchings, :unparsed, :boolean
  end
end
