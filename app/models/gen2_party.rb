class Gen2Party < ApplicationRecord
  belongs_to :gen2_entry
  has_many :gen2_pokemons
end
