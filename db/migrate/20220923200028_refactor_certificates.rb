class RefactorCertificates < ActiveRecord::Migration[7.0]
  def change
    add_column :certificates, :issuer_id, :bigint, foreign_key: { to_table: :certificates }
    add_column :certificates, :authority_id, :bigint
    remove_column :authorities, :certificate, :text
    rename_column :certificates, :pem, :x509
  end
end
