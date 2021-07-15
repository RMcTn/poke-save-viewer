class AddBadgesToGen1Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen1_entries, :badges, :string, array: true, default: []
  end
end
