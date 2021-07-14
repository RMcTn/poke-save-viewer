class CreatePokemons < ActiveRecord::Migration[6.1]
  def change
    create_table :pokemons do |t|
      t.integer :pokemon_id
      t.integer :current_hp
      t.integer :status_condition
      t.integer :type1
      t.integer :type2
      t.integer :move1_id
      t.integer :move2_id
      t.integer :move3_id
      t.integer :move4_id
      t.integer :max_hp
      t.integer :level
      t.string :nickname
      t.references :party, null: false, foreign_key: true

      t.timestamps
    end
  end
end
