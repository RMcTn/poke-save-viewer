class Pokemon < ApplicationRecord
  belongs_to :party, optional: true
  belongs_to :gen1_box, optional: true

  def same_as_pokemon?(other_pokemon)
    self.attributes.except("id", "party_id", "created_at", "updated_at", "gen1_box_id") ==
      other_pokemon.attributes.except("id", "party_id", "created_at", "updated_at", "gen1_box_id")
  end
end
