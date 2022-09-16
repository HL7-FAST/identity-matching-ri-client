class CreateCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :certificates do |t|
      t.text :pem

      t.timestamps
    end
  end
end
