class AddDriverslicenseAndGenderToIdentityMatchings < ActiveRecord::Migration[7.0]
  def change
    add_column :identity_matchings, :drivers_license, :string
    add_column :identity_matchings, :gender, :string
  end
end
