class Gen1HallOfFameEntry < ApplicationRecord
  belongs_to :gen1_entry
  has_many :gen1_hall_of_fame_pokemons, dependent: :destroy
end
