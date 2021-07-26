class AddBoxToPokemon < ActiveRecord::Migration[6.1]
  def change
    change_column_null :pokemons, :party_id, true
    change_table :pokemons do |t|
      t.references :gen1_box, null: true, foreign_key: true
    end
  end
end
