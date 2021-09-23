class Gen1Entry < ApplicationRecord
  validates :game, inclusion: { in: %w[red/blue yellow], message: "%{value} is not a valid game for generation 1" }
  has_one_attached :saveFile
  has_one :party, dependent: :delete
  has_many :gen1_hall_of_fame_entries, dependent: :delete_all
  has_many :gen1_boxes, dependent: :delete_all
  belongs_to :user, dependent: :delete
end
