class Gen1Box < ApplicationRecord
  belongs_to :gen1_entry
  has_many :pokemons, dependent: :destroy
end
