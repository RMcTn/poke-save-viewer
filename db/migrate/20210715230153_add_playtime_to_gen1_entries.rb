class AddPlaytimeToGen1Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen1_entries, :playtime, :integer
  end
end
