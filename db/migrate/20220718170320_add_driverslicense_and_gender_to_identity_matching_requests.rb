class AddDriverslicenseAndGenderToIdentityMatchingRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :identity_matching_requests, :drivers_license, :string
    add_column :identity_matching_requests, :gender, :string
  end
end
