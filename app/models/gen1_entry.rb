class Gen1Entry < ApplicationRecord
  has_one_attached :saveFile
  has_one :party
end
