class Gen2HallOfFamePokemon < ApplicationRecord
  belongs_to :gen2_hall_of_fame_entry

  def same_as_pokemon?(other_pokemon)
    self.attributes.except("id", "gen2_hall_of_fame_entry_id", "created_at", "updated_at") ==
      other_pokemon.attributes.except("id", "gen2_hall_of_fame_entry_id", "party_id", "created_at", "updated_at")
  end
end
