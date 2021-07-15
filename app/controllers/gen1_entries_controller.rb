class Gen1EntriesController < ApplicationController
  before_action :set_gen1_entry, only: %i[ show edit update destroy ]

  PokemonStruct = Struct.new(:pokemon_id, :current_hp, :status_condition, :type1, :type2, :move1_id, :move2_id, :move3_id, :move4_id, :max_hp, :level, :nickname)

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

  def get_player_name(save_file)
    player_name_offset = 0x2598
    player_name_max_size = 0xB
    save_file[player_name_offset..(player_name_offset + player_name_max_size)].bytes
  end

  def get_player_party(save_file)
    # See https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_I) for offsets
    party_pokemon = []
    party_offset = 0x2F2C
    party_size = save_file[party_offset].to_i
    pokemon_size = 0x2C
    pokemon_offset = party_offset + 8
    nicknames_offset = party_offset + 0x152
    max_nickname_size = 0xB

    (0..party_size - 1).each do |i|
      pokemon_id = save_file[pokemon_offset]
      current_hp = save_file[pokemon_offset + 1] + save_file[pokemon_offset + 2]
      status_condition = save_file[pokemon_offset + 4]
      type1 = save_file[pokemon_offset + 5]
      type2 = save_file[pokemon_offset + 6]
      move1_id = save_file[pokemon_offset + 8]
      move2_id = save_file[pokemon_offset + 9]
      move3_id = save_file[pokemon_offset + 0xA]
      move4_id = save_file[pokemon_offset + 0xB]
      level = save_file[pokemon_offset + 0x21]
      max_hp = save_file[pokemon_offset + 0x22] + save_file[pokemon_offset + 0x23]
      nickname_offset = nicknames_offset + (i * max_nickname_size)
      nickname = save_file[nickname_offset..nickname_offset + max_nickname_size]
      nickname = translate_game_string(nickname, @mappings)

      pokemon = PokemonStruct.new(pokemon_id, current_hp, status_condition, type1, type2, move1_id, move2_id, move3_id, move4_id, max_hp, level, nickname)
      party_pokemon.push(pokemon)
      pokemon_offset += pokemon_size
    end

    party_pokemon
  end

  def get_badges_obtained(save_file)
    gym_badges_offset = 0x29D6
    # Each bit is a badge, MSB to LSB is Boulder, Cascade, Thunder, Rainbow, Soul, Marsh, Volcano, Earth.
    badges_bit_field = save_file[gym_badges_offset]
    obtained_badges = []
    obtained_badges.push("Boulder") if (badges_bit_field >> 7 & 0x1) != 0
    obtained_badges.push("Cascade") if (badges_bit_field >> 6 & 0x1) != 0
    obtained_badges.push("Thunder") if (badges_bit_field >> 5 & 0x1) != 0
    obtained_badges.push("Rainbow") if (badges_bit_field >> 4 & 0x1) != 0
    obtained_badges.push("Soul") if (badges_bit_field >> 3 & 0x1) != 0
    obtained_badges.push("Marsh") if (badges_bit_field >> 2 & 0x1) != 0
    obtained_badges.push("Volcano") if (badges_bit_field >> 1 & 0x1) != 0
    obtained_badges.push("Earth") if (badges_bit_field & 0x1) != 0
  end

  def get_playtime_in_seconds(save_file)
    playtime_offset = 0x2CED
    playtime_hours = save_file[playtime_offset]
    playtime_minutes = save_file[playtime_offset + 2]
    playtime_seconds = save_file[playtime_offset + 3]
    (playtime_hours * 60 * 60) + (playtime_minutes * 60) + playtime_seconds
  end

  # GET /gen1_entries or /gen1_entries.json
  def index
    @gen1_entries = Gen1Entry.all
  end

  # GET /gen1_entries/1 or /gen1_entries/1.json
  def show
  end

  # GET /gen1_entries/new
  def new
    @gen1_entry = Gen1Entry.new
  end

  # GET /gen1_entries/1/edit
  def edit
  end

  # POST /gen1_entries or /gen1_entries.json
  def create
    @gen1_entry = Gen1Entry.new(gen1_entry_params)

    # TODO: Populate the mapping only once
    @mappings = Hash.new
    File.readlines("gen1_english_mappings.txt").each do |line|
      splits = line.split(' ')
      poke_char = splits[1].to_i(16)
      @mappings[poke_char] = splits[0]
    end
    uploaded_file = File.binread(params[:gen1_entry][:saveFile])
    player_name = translate_game_string(get_player_name(uploaded_file), @mappings)
    @gen1_entry.playerName = player_name

    party_pokemon = get_player_party(uploaded_file.bytes)
    party = Party.create(gen1_entry: @gen1_entry)
    party_pokemon.each do |pokemon|
      created_pokemon = Pokemon.create(party: party, pokemon_id: pokemon.pokemon_id, current_hp: pokemon.current_hp, status_condition: pokemon.status_condition, type1: pokemon.type1, type2: pokemon.type2, move1_id: pokemon.move1_id, move2_id: pokemon.move2_id, move3_id: pokemon.move3_id, move4_id: pokemon.move4_id, max_hp: pokemon.max_hp, level: pokemon.level, nickname: pokemon.nickname)
      party.pokemons.push(created_pokemon)

    end

    obtained_badges = get_badges_obtained(uploaded_file.bytes)
    @gen1_entry.badges = obtained_badges

    playtime = get_playtime_in_seconds(uploaded_file.bytes)
    @gen1_entry.playtime = playtime

    # Baseline: Player name, each pokemon in party, gyms completed, each pokemon in boxes, time played, elite 4, hall of fame
    # https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_I)
    # Potentially different offsets for different pokemon gen 1 versions (red, blue, yellow). Just stick with red for now
    respond_to do |format|
      if @gen1_entry.save
        format.html { redirect_to @gen1_entry, notice: "Gen1 entry was successfully created." }
        format.json { render :show, status: :created, location: @gen1_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gen1_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gen1_entries/1 or /gen1_entries/1.json
  def update
    respond_to do |format|
      if @gen1_entry.update(gen1_entry_params)
        format.html { redirect_to @gen1_entry, notice: "Gen1 entry was successfully updated." }
        format.json { render :show, status: :ok, location: @gen1_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gen1_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gen1_entries/1 or /gen1_entries/1.json
  def destroy
    @gen1_entry.destroy
    respond_to do |format|
      format.html { redirect_to gen1_entries_url, notice: "Gen1 entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gen1_entry
    @gen1_entry = Gen1Entry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def gen1_entry_params
    params.require(:gen1_entry).permit(:saveFile)
  end
end
