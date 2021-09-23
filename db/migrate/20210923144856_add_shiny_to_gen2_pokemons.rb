class AddShinyToGen2Pokemons < ActiveRecord::Migration[6.1]
  def change
    add_column :gen2_pokemons, :is_shiny, :boolean
  end
end
