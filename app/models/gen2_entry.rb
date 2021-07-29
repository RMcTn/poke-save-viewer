class Gen2Entry < ApplicationRecord
  has_one_attached :save_file
  has_one :gen2_party
  # TODO: Look into polymorhpic relations in rails, might solve the duplicating of pokemon/parties between gen1/2
end
