class AddUserToGen1Entries < ActiveRecord::Migration[6.1]
  def change
    change_table :gen1_entries do |t|
      t.references :user, null: false, foreign_key: true
    end
  end
end
