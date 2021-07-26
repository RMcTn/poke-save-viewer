class Pokemon < ApplicationRecord
  belongs_to :party, optional: true
  belongs_to :gen1_box, optional: true
end
