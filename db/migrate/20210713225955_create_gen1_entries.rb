class CreateGen1Entries < ActiveRecord::Migration[6.1]
  def change
    create_table :gen1_entries do |t|
      t.text :playerName

      t.timestamps
    end
  end
end
