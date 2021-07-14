class CreateParties < ActiveRecord::Migration[6.1]
  def change
    create_table :parties do |t|
      t.references :gen1_entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
