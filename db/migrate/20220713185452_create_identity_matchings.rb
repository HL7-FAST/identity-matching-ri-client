class CreateIdentityMatchingRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :identity_matchings do |t|
      t.string :full_name
      t.date :date_of_birth
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :email
      t.string :mobile
      t.integer :response_status
      t.text :response_json

      t.timestamps
    end
  end
end
