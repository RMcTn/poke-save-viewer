class Gen2EntriesController < ApplicationController
  before_action :set_gen2_entry, only: %i[ show edit update destroy ]

  Gen2PokemonStruct = Struct.new(:pokemon_id, :current_hp, :status_condition, :type1_id, :type2_id, :move1_id, :move2_id, :move3_id, :move4_id, :max_hp, :level, :nickname, keyword_init: true)

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

  # GET /gen2_entries or /gen2_entries.json
  def index
    @gen2_entries = Gen2Entry.all
  end

  # GET /gen2_entries/1 or /gen2_entries/1.json
  def show
  end

  # GET /gen2_entries/new
  def new
    @gen2_entry = Gen2Entry.new
  end

  # GET /gen2_entries/1/edit
  def edit
  end

  def get_pokemon_from_save(save_file, pokemon_offset, nickname_offset)
    # TODO: Type has to be calculated elsewhere, use poke api for this?
    #
    # TODO: Egg has an id of 0xFD
    pokemon_id = save_file[pokemon_offset]
    move1_id = save_file[pokemon_offset + 2]
    move2_id = save_file[pokemon_offset + 3]
    move3_id = save_file[pokemon_offset + 4]
    move4_id = save_file[pokemon_offset + 5]
    status_condition = save_file[pokemon_offset + 0x20]
    max_nickname_size = 0xB
    nickname = save_file[nickname_offset..nickname_offset + max_nickname_size]
    nickname = translate_game_string(nickname, @mappings)
    level = save_file[pokemon_offset + 0x1F]
    current_hp = (save_file[pokemon_offset + 0x22] << 8) + save_file[pokemon_offset + 0x23]
    max_hp = (save_file[pokemon_offset + 0x24] << 8) + save_file[pokemon_offset + 0x25]
    pokemon = Gen2PokemonStruct.new(pokemon_id: pokemon_id, current_hp: current_hp, status_condition: status_condition, type1_id: 0, type2_id: 0, move1_id: move1_id, move2_id: move2_id, move3_id: move3_id, move4_id: move4_id, max_hp: max_hp, level: level, nickname: nickname)

  end

  def get_player_party(save_file)
    # See https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_II) for offsets
    party_pokemon = []
    party_offset = 0x288A
    party_size = save_file[party_offset].to_i
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
      pokemon = get_pokemon_from_save(save_file, pokemon_offset, nickname_offset)
      party_pokemon.push(pokemon)
      pokemon_offset += pokemon_size_in_bytes
    end

    party_pokemon
  end

  def get_player_name(save_file)
    player_name_offset = 0x200B
    player_name_max_size = 0xB
    save_file[player_name_offset..(player_name_offset + player_name_max_size)].bytes
  end

  def get_playtime_in_seconds(save_file)
    playtime_offset = 0x2053
    playtime_hours = save_file[playtime_offset + 1]
    playtime_minutes = save_file[playtime_offset + 2]
    playtime_seconds = save_file[playtime_offset + 3]
    (playtime_hours * 60 * 60) + (playtime_minutes * 60) + playtime_seconds
  end

  def get_johto_badges(save_file)
    johto_badges_offset = 0x23E4
    # Each bit is a badge, MSB to LSB is Zephyr, Insect, Plain, Fog, Storm, Mineral, Glacier, Rising
    badges_bit_field = save_file[johto_badges_offset]
    obtained_badges = []
    obtained_badges.push("Zephyr") if (badges_bit_field >> 7 & 0x1) != 0
    obtained_badges.push("Insect") if (badges_bit_field >> 6 & 0x1) != 0
    obtained_badges.push("Plain") if (badges_bit_field >> 5 & 0x1) != 0
    obtained_badges.push("Fog") if (badges_bit_field >> 4 & 0x1) != 0
    obtained_badges.push("Storm") if (badges_bit_field >> 3 & 0x1) != 0
    obtained_badges.push("Mineral") if (badges_bit_field >> 2 & 0x1) != 0
    obtained_badges.push("Glacier") if (badges_bit_field >> 1 & 0x1) != 0
    obtained_badges.push("Rising") if (badges_bit_field & 0x1) != 0
  end

  # POST /gen2_entries or /gen2_entries.json
  def create
    @gen2_entry = Gen2Entry.new(gen2_entry_params)

    # TODO: Populate the mapping only once
    # TODO: Check if gen2 has different character mappings
    @mappings = Hash.new
    File.readlines("gen1_english_mappings.txt").each do |line|
      splits = line.split(' ')
      poke_char = splits[1].to_i(16)
      @mappings[poke_char] = splits[0]
    end

    # TODO: Possible to have different offsets from gold/silver to crystal, will need to handle

    uploaded_file = File.binread(params[:gen2_entry][:save_file])
    player_name = translate_game_string(get_player_name(uploaded_file), @mappings)

    @gen2_entry.player_name = player_name

    playtime = get_playtime_in_seconds(uploaded_file.bytes)
    @gen2_entry.playtime = playtime

    party_pokemon = get_player_party(uploaded_file.bytes)
    party = Gen2Party.create(gen2_entry: @gen2_entry)
    party_pokemon.each do |pokemon|
      created_pokemon = Gen2Pokemon.create(gen2_party: party, pokemon_id: pokemon.pokemon_id, current_hp: pokemon.current_hp, status_condition: pokemon.status_condition, type1: pokemon.type1_id, type2: pokemon.type2_id, move1_id: pokemon.move1_id, move2_id: pokemon.move2_id, move3_id: pokemon.move3_id, move4_id: pokemon.move4_id, max_hp: pokemon.max_hp, level: pokemon.level, nickname: pokemon.nickname)
      party.gen2_pokemons.push(created_pokemon)
    end

    johto_badges = get_johto_badges(uploaded_file.bytes)
    @gen2_entry.johto_badges = johto_badges

    respond_to do |format|
      if @gen2_entry.save
        format.html { redirect_to @gen2_entry, notice: "Gen2 entry was successfully created." }
        format.json { render :show, status: :created, location: @gen2_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gen2_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gen2_entries/1 or /gen2_entries/1.json
  def update
    respond_to do |format|
      if @gen2_entry.update(gen2_entry_params)
        format.html { redirect_to @gen2_entry, notice: "Gen2 entry was successfully updated." }
        format.json { render :show, status: :ok, location: @gen2_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gen2_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gen2_entries/1 or /gen2_entries/1.json
  def destroy
    @gen2_entry.destroy
    respond_to do |format|
      format.html { redirect_to gen2_entries_url, notice: "Gen2 entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gen2_entry
    @gen2_entry = Gen2Entry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def gen2_entry_params
    params.require(:gen2_entry).permit(:save_file)
  end
end
