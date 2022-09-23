class RefactorCertificates < ActiveRecord::Migration[7.0]
  def change
    add_column :certificates, :issuer_id, :bigint, foreign_key: { to_table: :certificates }
    add_column :certificates, :authority_id, :bigint
  end
end
