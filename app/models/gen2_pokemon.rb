class Gen2Pokemon < ApplicationRecord
  belongs_to :gen2_party

  def same_as_pokemon?(other_pokemon)
    self.attributes.except("id", "gen2_party_id", "created_at", "updated_at") ==
      other_pokemon.attributes.except("id", "gen2_party_id", "created_at", "updated_at")
  end
end
