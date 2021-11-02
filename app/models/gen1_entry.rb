class Gen1Entry < ApplicationRecord
  validates :game, inclusion: { in: %w[red/blue yellow], message: "%{value} is not a valid game for generation 1" }
  has_one_attached :saveFile
  has_one :party, dependent: :destroy
  has_many :gen1_hall_of_fame_entries, dependent: :destroy
  has_many :gen1_boxes, dependent: :destroy
  belongs_to :user 
  has_many :pokemons, :through => :party
end
