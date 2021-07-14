class Party < ApplicationRecord
  belongs_to :gen1_entry
  has_many :pokemons
end
