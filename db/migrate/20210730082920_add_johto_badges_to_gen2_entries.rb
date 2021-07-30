class AddJohtoBadgesToGen2Entries < ActiveRecord::Migration[6.1]
  def change
    add_column :gen2_entries, :johto_badges, :string, array: true, default: []
  end
end
