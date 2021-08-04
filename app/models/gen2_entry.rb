class Gen2Entry < ApplicationRecord
  validates :game, inclusion: { in: %w[gold silver crystal], message: "%{value} is not a valid game for generation 2" }
  # TODO Validate save_file size
  has_one_attached :save_file
  has_one :gen2_party
  # TODO: Look into polymorhpic relations in rails, might solve the duplicating of pokemon/parties between gen1/2
  has_many :gen2_hall_of_fame_entries

  # TODO Move gen entry controller logic to models, will help with errors
end
