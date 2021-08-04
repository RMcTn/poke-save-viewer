class AddGameToGen2Entry < ActiveRecord::Migration[6.1]
  def change
    add_column :gen2_entries, :game, :string
  end
end
