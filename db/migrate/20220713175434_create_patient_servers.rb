class CreatePatientServers < ActiveRecord::Migration[7.0]
  def change
    create_table :patient_servers do |t|
      t.text :base

      t.timestamps
    end
  end
end
