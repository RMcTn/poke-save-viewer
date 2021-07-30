class AddKantoBadgesToGen2Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen2_entries, :kanto_badges, :string, array: true, default: []
  end
end
