class AddPlaytimeToGen2Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen2_entries, :playtime, :integer
  end
end
