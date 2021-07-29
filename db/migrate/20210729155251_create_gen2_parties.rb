class CreateGen2Parties < ActiveRecord::Migration[6.1]
  def change
    create_table :gen2_parties do |t|
      t.references :gen2_entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
