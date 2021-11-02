class Gen2HallOfFameEntry < ApplicationRecord
  belongs_to :gen2_entry
  has_many :gen2_hall_of_fame_pokemons, dependent: :destroy
end
