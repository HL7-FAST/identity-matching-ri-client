class CreateAuthorities < ActiveRecord::Migration[7.0]
  def change
    create_table :authorities do |t|
      t.string :name, null: false
      t.text :certificate
      t.text :private_key

      t.timestamps
    end
  end
end
