class CreateGen2Entries < ActiveRecord::Migration[6.1]
  def change
    create_table :gen2_entries do |t|
      t.text :player_name

      t.timestamps
    end
  end
end
