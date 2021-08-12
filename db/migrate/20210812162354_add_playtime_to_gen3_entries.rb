class AddPlaytimeToGen3Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen3_entries, :playtime, :integer
  end
end
