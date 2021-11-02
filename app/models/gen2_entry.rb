class Gen2Entry < ApplicationRecord
  validates :game, inclusion: { in: %w[gold/silver crystal], message: "Save file is not a valid Gold/Silver or Crystal save file" }
  # TODO Validate save_file size
  has_one_attached :save_file
  has_one :gen2_party, dependent: :destroy
  # TODO: Look into polymorhpic relations in rails, might solve the duplicating of pokemon/parties between gen1/2
  has_many :gen2_hall_of_fame_entries, dependent: :destroy

  belongs_to :user

  # NOTE: Types here contain all pokemon (even outside of gen2 and beyond) and possibly fairy type (non existant in gen 2)
  # TODO: Clean up types here
  @@pokemon_types = ["grass/poison", "grass/poison", "grass/poison", "fire", "fire", "fire/flying", "water", "water", "water", "bug", "bug", "bug/flying", "bug/poison", "bug/poison", "bug/poison", "normal/flying", "normal/flying", "normal/flying", "normal", "normal", "normal/flying", "normal/flying", "poison", "poison", "electric", "electric", "ground", "ground", "poison", "poison", "poison/ground", "poison", "poison", "poison/ground", "normal", "normal", "fire", "fire", "normal", "normal", "poison/flying", "poison/flying", "grass/poison", "grass/poison", "grass/poison", "bug/grass", "bug/grass", "bug/poison", "bug/poison", "ground", "ground", "normal", "normal", "water", "water", "fighting", "fighting", "fire", "fire", "water", "water", "water/fighting", "psychic", "psychic", "psychic", "fighting", "fighting", "fighting", "grass/poison", "grass/poison", "grass/poison", "water/poison", "water/poison", "rock/ground", "rock/ground", "rock/ground", "fire", "fire", "water/psychic", "water/psychic", "electric/steel", "electric/steel", "normal/flying", "normal/flying", "normal/flying", "water", "water/ice", "poison", "poison", "water", "water/ice", "ghost/poison", "ghost/poison", "ghost/poison", "rock/ground", "psychic", "psychic", "water", "water", "electric", "electric", "grass/psychic", "grass/psychic", "ground", "ground", "fighting", "fighting", "normal", "poison", "poison", "ground/rock", "ground/rock", "normal", "grass", "normal", "water", "water", "water", "water", "water", "water/psychic", "psychic", "bug/flying", "ice/psychic", "electric", "fire", "bug", "normal", "water", "water/flying", "water/ice", "normal", "normal", "water", "electric", "fire", "normal", "rock/water", "rock/water", "rock/water", "rock/water", "rock/flying", "normal", "ice/flying", "electric/flying", "fire/flying", "dragon", "dragon", "dragon/flying", "psychic", "psychic", "grass", "grass", "grass", "fire", "fire", "fire", "water", "water", "water", "normal", "normal", "normal/flying", "normal/flying", "bug/flying", "bug/flying", "bug/poison", "bug/poison", "poison/flying", "water/electric", "water/electric", "electric", "normal", "normal", "normal", "normal/flying", "psychic/flying", "psychic/flying", "electric", "electric", "electric", "grass", "water", "water", "rock", "water", "grass/flying", "grass/flying", "grass/flying", "normal", "grass", "grass", "bug/flying", "water/ground", "water/ground", "psychic", "dark", "dark/flying", "water/psychic", "ghost", "psychic", "psychic", "normal/psychic", "bug", "bug/steel", "normal", "ground/flying", "steel/ground", "normal", "normal", "water/poison", "bug/steel", "bug/rock", "bug/fighting", "dark/ice", "normal", "normal", "fire", "fire/rock", "ice/ground", "ice/ground", "water/rock", "water", "water", "ice/flying", "water/flying", "steel/flying", "dark/fire", "dark/fire", "water/dragon", "ground", "ground", "normal", "normal", "normal", "fighting", "fighting", "ice/psychic", "electric", "fire", "normal", "normal", "electric", "fire", "water", "rock/ground", "rock/ground", "rock/dark", "psychic/flying", "fire/flying", "psychic/grass", "grass", "grass", "grass", "fire", "fire/fighting", "fire/fighting", "water", "water/ground", "water/ground", "dark", "dark", "normal", "normal", "bug", "bug", "bug/flying", "bug", "bug/poison", "water/grass", "water/grass", "water/grass", "grass", "grass/dark", "grass/dark", "normal/flying", "normal/flying", "water/flying", "water/flying", "psychic", "psychic", "psychic", "bug/water", "bug/flying", "grass", "grass/fighting", "normal", "normal", "normal", "bug/ground", "bug/flying", "bug/ghost", "normal", "normal", "normal", "fighting", "fighting", "normal", "rock", "normal", "normal", "dark/ghost", "steel", "steel/rock", "steel/rock", "steel/rock", "fighting/psychic", "fighting/psychic", "electric", "electric", "electric", "electric", "bug", "bug", "grass/poison", "poison", "poison", "water/dark", "water/dark", "water", "water", "fire/ground", "fire/ground", "fire", "psychic", "psychic", "normal", "ground", "ground/dragon", "ground/dragon", "grass", "grass/dark", "normal/flying", "dragon/flying", "normal", "poison", "rock/psychic", "rock/psychic", "water/ground", "water/ground", "water", "water/dark", "ground/psychic", "ground/psychic", "rock/grass", "rock/grass", "rock/bug", "rock/bug", "water", "water", "normal", "normal", "ghost", "ghost", "ghost", "ghost", "grass/flying", "psychic", "dark", "psychic", "ice", "ice", "ice/water", "ice/water", "ice/water", "water", "water", "water", "water/rock", "water", "dragon", "dragon", "dragon/flying", "steel/psychic", "steel/psychic", "steel/psychic", "rock", "ice", "steel", "dragon/psychic", "dragon/psychic", "water", "ground", "dragon/flying", "steel/psychic", "psychic", "grass", "grass", "grass/ground", "fire", "fire/fighting", "fire/fighting", "water", "water", "water/steel", "normal/flying", "normal/flying", "normal/flying", "normal", "normal/water", "bug", "bug", "electric", "electric", "electric", "grass/poison", "grass/poison", "rock", "rock", "rock/steel", "rock/steel", "bug", "bug/grass", "bug/flying", "bug/flying", "bug/flying", "electric", "water", "water", "grass", "grass", "water", "water/ground", "normal", "ghost/flying", "ghost/flying", "normal", "normal", "ghost", "dark/flying", "normal", "normal", "psychic", "poison/dark", "poison/dark", "steel/psychic", "steel/psychic", "rock", "psychic/fairy", "normal", "normal/flying", "ghost/dark", "dragon/ground", "dragon/ground", "dragon/ground", "normal", "fighting", "fighting/steel", "ground", "ground", "poison/bug", "poison/dark", "poison/fighting", "poison/fighting", "grass", "water", "water", "water/flying", "grass/ice", "grass/ice", "dark/ice", "electric/steel", "normal", "ground/rock", "grass", "electric", "fire", "fairy/flying", "bug/flying", "grass", "ice", "ground/flying", "ice/ground", "normal", "psychic/fighting", "rock/steel", "ghost", "ice/ghost", "electric/ghost", "psychic", "psychic", "psychic", "steel/dragon", "water/dragon", "fire/steel", "normal", "ghost/dragon", "psychic", "water", "water", "dark", "grass", "normal", "psychic/fire", "grass", "grass", "grass", "fire", "fire/fighting", "fire/fighting", "water", "water", "water", "normal", "normal", "normal", "normal", "normal", "dark", "dark", "grass", "grass", "fire", "fire", "water", "water", "psychic", "psychic", "normal/flying", "normal/flying", "normal/flying", "electric", "electric", "rock", "rock", "rock", "psychic/flying", "psychic/flying", "ground", "ground/steel", "normal", "fighting", "fighting", "fighting", "water", "water/ground", "water/ground", "fighting", "fighting", "bug/grass", "bug/grass", "bug/grass", "bug/poison", "bug/poison", "bug/poison", "grass/fairy", "grass/fairy", "grass", "grass", "water", "ground/dark", "ground/dark", "ground/dark", "fire", "fire", "grass", "bug/rock", "bug/rock", "dark/fighting", "dark/fighting", "psychic/flying", "ghost", "ghost", "water/rock", "water/rock", "rock/flying", "rock/flying", "poison", "poison", "dark", "dark", "normal", "normal", "psychic", "psychic", "psychic", "psychic", "psychic", "psychic", "water/flying", "water/flying", "ice", "ice", "ice", "normal/grass", "normal/grass", "electric/flying", "bug", "bug/steel", "grass/poison", "grass/poison", "water/ghost", "water/ghost", "water", "bug/electric", "bug/electric", "grass/steel", "grass/steel", "steel", "steel", "steel", "electric", "electric", "electric", "psychic", "psychic", "ghost/fire", "ghost/fire", "ghost/fire", "dragon", "dragon", "dragon", "ice", "ice", "ice", "bug", "bug", "ground/electric", "fighting", "fighting", "dragon", "ground/ghost", "ground/ghost", "dark/steel", "dark/steel", "normal", "normal/flying", "normal/flying", "dark/flying", "dark/flying", "fire", "bug/steel", "dark/dragon", "dark/dragon", "dark/dragon", "bug/fire", "bug/fire", "steel/fighting", "rock/fighting", "grass/fighting", "flying", "electric/flying", "dragon/fire", "dragon/electric", "ground/flying", "dragon/ice", "water/fighting", "normal/psychic", "bug/steel", "grass", "grass", "grass/fighting", "fire", "fire", "fire/psychic", "water", "water", "water/dark", "normal", "normal/ground", "normal/flying", "fire/flying", "fire/flying", "bug", "bug", "bug/flying", "fire/normal", "fire/normal", "fairy", "fairy", "fairy", "grass", "grass", "fighting", "fighting/dark", "normal", "psychic", "psychic", "steel/ghost", "steel/ghost", "steel/ghost", "fairy", "fairy", "fairy", "fairy", "dark/psychic", "dark/psychic", "rock/water", "rock/water", "poison/water", "poison/dragon", "water", "water", "electric/normal", "electric/normal", "rock/dragon", "rock/dragon", "rock/ice", "rock/ice", "fairy", "fighting/flying", "electric/fairy", "rock/fairy", "dragon", "dragon", "dragon", "steel/fairy", "ghost/grass", "ghost/grass", "ghost/grass", "ghost/grass", "ice", "ice", "flying/dragon", "flying/dragon", "fairy", "dark/flying", "dragon/ground", "rock/fairy", "psychic/ghost", "fire/water", "grass/flying", "grass/flying", "grass/ghost", "fire", "fire", "fire/dark", "water", "water", "water/fairy", "normal/flying", "normal/flying", "normal/flying", "normal", "normal", "bug", "bug/electric", "bug/electric", "fighting", "fighting/ice", "fire/flying", "bug/fairy", "bug/fairy", "rock", "rock", "water", "poison/water", "poison/water", "ground", "ground", "water/bug", "water/bug", "grass", "grass", "grass/fairy", "grass/fairy", "poison/fire", "poison/fire", "normal/fighting", "normal/fighting", "grass", "grass", "grass", "fairy", "normal/psychic", "fighting", "bug/water", "bug/water", "ghost/ground", "ghost/ground", "water", "normal", "normal", "rock/flying", "normal", "fire/dragon", "electric/steel", "ghost/fairy", "water/psychic", "normal/dragon", "ghost/grass", "dragon", "dragon/fighting", "dragon/fighting", "electric/fairy", "psychic/fairy", "grass/fairy", "water/fairy", "psychic", "psychic", "psychic/steel", "psychic/ghost", "rock/poison", "bug/fighting", "bug/fighting", "electric", "steel/flying", "grass/steel", "dark/dragon", "psychic", "steel/fairy", "fighting/ghost", "poison", "poison/dragon", "rock/steel", "fire/ghost", "electric", "steel", "steel", "grass", "grass", "grass", "fire", "fire", "fire", "water", "water", "water", "normal", "normal", "flying", "flying", "flying/steel", "bug", "bug/psychic", "bug/psychic", "dark", "dark", "grass", "grass", "normal", "normal", "water", "water/rock", "electric", "electric", "rock", "rock/fire", "rock/fire", "grass/dragon", "grass/dragon", "grass/dragon", "ground", "ground", "flying/water", "water", "water", "electric/poison", "electric/poison", "fire/bug", "fire/bug", "fighting", "fighting", "ghost", "ghost", "psychic", "psychic", "psychic/fairy", "dark/fairy", "dark/fairy", "dark/fairy", "dark/normal", "steel", "ghost", "fighting", "ice/psychic", "ground/ghost", "fairy", "fairy", "fighting", "electric", "ice/bug", "ice/bug", "rock", "ice", "psychic/normal", "electric/dark", "steel", "steel", "electric/dragon", "electric/ice", "water/dragon", "water/ice", "steel/dragon", "dragon/ghost", "dragon/ghost", "dragon/ghost", "fairy/steel", "fighting/steel", "poison/dragon", "fighting", "fighting/dark", "dark/grass", "electric", "dragon", "ice", "ghost", "psychic/grass"]
  @@pokemon_types_mapping = { "normal" => 0, "fighting" => 1, "flying" => 2, "poison" => 3, "ground" => 4, "rock" => 5, "bug" => 7, "ghost" => 8, "fire" => 20, "water" => 21, "grass" => 22, "electric" => 23, "psychic" => 24, "ice" => 25, "dragon" => 26, "dark" => 27, "steel" => 28 }

  Gen2PokemonStruct = Struct.new(:pokemon_id, :current_hp, :status_condition, :type1_id, :type2_id, :move1_id, :move2_id, :move3_id, :move4_id, :max_hp, :level, :nickname, :is_shiny, keyword_init: true)

  def is_valid_gold_silver_party?(uploaded_file)
    party_offset = 0x288A
    party_size = uploaded_file[party_offset].to_i
    uploaded_file[party_offset + party_size + 1] == 0xFF
  end

  def is_valid_crystal_party?(uploaded_file)
    party_offset = 0x2865
    party_size = uploaded_file[party_offset].to_i
    uploaded_file[party_offset + party_size + 1] == 0xFF
  end

  def translate_game_string(game_str, character_mapping)
    translated_string = ""
    terminating_character = 0x50
    game_str.each do |byte|
      return translated_string if (byte == '0') || (byte == terminating_character)

      mapped_character = character_mapping[byte]
      translated_string += mapped_character unless mapped_character.nil?
    end
    translated_string
  end

  def get_translated_player_name(uploaded_file, character_mapping)
    translate_game_string(get_player_name(uploaded_file), character_mapping)
  end

  def get_player_name(uploaded_file)
    player_name_offset = 0x200B
    player_name_max_size = 0xB
    uploaded_file[player_name_offset..(player_name_offset + player_name_max_size)]
  end

  def get_playtime_in_seconds(uploaded_file)
    playtime_offset = 0x2054
    if game == "crystal"
      playtime_offset = 0x2053
    end
    playtime_hours = uploaded_file[playtime_offset]
    playtime_minutes = uploaded_file[playtime_offset + 1]
    playtime_seconds = uploaded_file[playtime_offset + 2]
    (playtime_hours * 60 * 60) + (playtime_minutes * 60) + playtime_seconds
  end

  def get_player_party(uploaded_file, character_mapping)
    # See https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_II) for offsets
    party_pokemon = []
    party_offset = 0x288A
    if game == "crystal"
      party_offset = 0x2865
    end
    party_size = uploaded_file[party_offset].to_i
    # Amount of characters in a string varies from English to Japanese versions. See https://bulbapedia.bulbagarden.net/wiki/Save_data_structure_(Generation_II)#Pok.C3.A9mon_lists
    # Focusing on English only for now
    pokemon_size_in_bytes = 48
    name_string_size_in_bytes = 11
    pokemon_offset = party_offset + 8
    max_pokemon_in_party = 6
    nicknames_offset = party_offset + 1 + (max_pokemon_in_party + 1) + (max_pokemon_in_party * pokemon_size_in_bytes) + (max_pokemon_in_party * name_string_size_in_bytes)
    max_nickname_size = 0xB
    (0..party_size - 1).each do |i|
      nickname_offset = nicknames_offset + (i * max_nickname_size)
      pokemon = get_pokemon_from_save(uploaded_file, pokemon_offset, nickname_offset, character_mapping)
      party_pokemon.push(pokemon)
      pokemon_offset += pokemon_size_in_bytes
    end

    party_pokemon
  end

  def get_pokemon_from_save(save_file, pokemon_offset, nickname_offset, character_mapping)
    # TODO: Egg has an id of 0xFD
    pokemon_id = save_file[pokemon_offset]

    pokemon_typing = @@pokemon_types[pokemon_id - 1]
    types = pokemon_typing.split('/')

    # TODO: Swap type ids for type names in schema?
    type1_id = @@pokemon_types_mapping[types[0]]
    type2_id = if types.length > 1
                 @@pokemon_types_mapping[types[1]]
               else
                 type1_id
               end

    attack_iv = save_file[pokemon_offset + 0x15] >> 4
    defence_iv = save_file[pokemon_offset + 0x15] & 15
    speed_iv = save_file[pokemon_offset + 0x16] >> 4
    special_iv = save_file[pokemon_offset + 0x16] & 15
    shiny_attack_ivs = [2, 3, 6, 7, 10, 11, 14, 15]
    is_shiny = defence_iv == 10 && speed_iv == 10 && special_iv == 10 && shiny_attack_ivs.include?(attack_iv)

    # TODO: These move IDs are just indexes into the move list. Will need to sort something out
    move1_id = save_file[pokemon_offset + 2]
    move2_id = save_file[pokemon_offset + 3]
    move3_id = save_file[pokemon_offset + 4]
    move4_id = save_file[pokemon_offset + 5]
    status_condition = save_file[pokemon_offset + 0x20]
    max_nickname_size = 0xB
    nickname = save_file[nickname_offset..nickname_offset + max_nickname_size]
    nickname = translate_game_string(nickname, character_mapping)
    level = save_file[pokemon_offset + 0x1F]
    current_hp = (save_file[pokemon_offset + 0x22] << 8) + save_file[pokemon_offset + 0x23]
    max_hp = (save_file[pokemon_offset + 0x24] << 8) + save_file[pokemon_offset + 0x25]
    pokemon = Gen2PokemonStruct.new(pokemon_id: pokemon_id, current_hp: current_hp, status_condition: status_condition, type1_id: type1_id, type2_id: type2_id, move1_id: move1_id, move2_id: move2_id, move3_id: move3_id, move4_id: move4_id, max_hp: max_hp, level: level, nickname: nickname, is_shiny: is_shiny)
  end

  def get_johto_badges(uploaded_file)
    johto_badges_offset = 0x23E4
    if game == "crystal"
      johto_badges_offset = 0x23E5
    end
    badges_bit_field = uploaded_file[johto_badges_offset]
    obtained_badges = []
    obtained_badges.push("Zephyr") if (badges_bit_field >> 0 & 0x1) != 0
    obtained_badges.push("Insect") if (badges_bit_field >> 1 & 0x1) != 0
    obtained_badges.push("Plain") if (badges_bit_field >> 2 & 0x1) != 0
    obtained_badges.push("Fog") if (badges_bit_field >> 3 & 0x1) != 0
    obtained_badges.push("Storm") if (badges_bit_field >> 4 & 0x1) != 0
    obtained_badges.push("Mineral") if (badges_bit_field >> 5 & 0x1) != 0
    obtained_badges.push("Glacier") if (badges_bit_field >> 6 & 0x1) != 0
    obtained_badges.push("Rising") if (badges_bit_field >> 7 & 0x1) != 0
    obtained_badges
  end

  def get_kanto_badges(uploaded_file)
    kanto_badges_offset = 0x23E5
    if game == "crystal"
      kanto_badges_offset = 0x23E6
    end
    badges_bit_field = uploaded_file[kanto_badges_offset]
    obtained_badges = []
    obtained_badges.push("Boulder") if (badges_bit_field >> 0 & 0x1) != 0
    obtained_badges.push("Cascade") if (badges_bit_field >> 1 & 0x1) != 0
    obtained_badges.push("Thunder") if (badges_bit_field >> 2 & 0x1) != 0
    obtained_badges.push("Rainbow") if (badges_bit_field >> 3 & 0x1) != 0
    obtained_badges.push("Soul") if (badges_bit_field >> 4 & 0x1) != 0
    obtained_badges.push("Marsh") if (badges_bit_field >> 5 & 0x1) != 0
    obtained_badges.push("Volcano") if (badges_bit_field >> 6 & 0x1) != 0
    obtained_badges.push("Earth") if (badges_bit_field >> 7 & 0x1) != 0
    obtained_badges
  end

  def get_hall_of_fame_entries(uploaded_file, character_mapping)
    hall_of_fame_offset = 0x321A
    if game == "crystal"
      hall_of_fame_offset = 0x32C0
    end
    max_hall_of_fame_record_count = 50
    pokemon_size = 16
    max_pokemon_per_record = 6
    hall_of_fame_entries = []
    max_nickname_size = 0xB
    (0..max_hall_of_fame_record_count - 1).each do |i|
      # TODO Try with an entry of 5 pokemon
      current_offset = hall_of_fame_offset + (pokemon_size * max_pokemon_per_record * i) + (2 * i) # 2 Bytes for FF terminatior and hall of fame id
      hall_of_fame_id = uploaded_file[current_offset]
      return hall_of_fame_entries if hall_of_fame_id.zero?

      hall_of_fame_entries.push([])
      (0..max_pokemon_per_record - 1).each do |j|
        pokemon_offset = current_offset + (j * pokemon_size)
        pokemon_id = uploaded_file[pokemon_offset + 1]
        next if pokemon_id.zero? || pokemon_id == 0xFF

        level = uploaded_file[pokemon_offset + 6]
        nickname = uploaded_file[pokemon_offset + 7..pokemon_offset + 7 + max_nickname_size]
        nickname = translate_game_string(nickname, character_mapping)
        pokemon = Gen2PokemonStruct.new(pokemon_id: pokemon_id, level: level, nickname: nickname)
        pokemons = hall_of_fame_entries[i]
        pokemons.push(pokemon)
      end
    end
    hall_of_fame_entries
  end

end
