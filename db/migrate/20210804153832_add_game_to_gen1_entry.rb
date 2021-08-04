class AddGameToGen1Entry < ActiveRecord::Migration[6.1]
  def change
    add_column :gen1_entries, :game, :string
  end
end
