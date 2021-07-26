class Gen1Entry < ApplicationRecord
  has_one_attached :saveFile
  has_one :party
  has_many :gen1_hall_of_fame_entries
  has_many :gen1_boxes
end
