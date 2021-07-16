class CreateGen1HallOfFameEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :gen1_hall_of_fame_entries do |t|
      t.references :gen1_entry, null: false, foreign_key: true

      t.timestamps
    end

  end
end
