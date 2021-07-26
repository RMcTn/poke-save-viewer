class CreateGen1Boxes < ActiveRecord::Migration[6.1]
  def change
    create_table :gen1_boxes do |t|
      t.references :gen1_entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
