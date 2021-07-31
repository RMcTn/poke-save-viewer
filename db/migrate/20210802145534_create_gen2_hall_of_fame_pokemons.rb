class CreateGen2HallOfFamePokemons < ActiveRecord::Migration[6.1]
  def change
    create_table :gen2_hall_of_fame_pokemons do |t|
      t.integer :pokemon_id
      t.integer :level
      t.string :nickname
      t.references :gen2_hall_of_fame_entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
