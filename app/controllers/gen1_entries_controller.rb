class Gen1EntriesController < ApplicationController
  before_action :set_gen1_entry, only: %i[ show edit update destroy ]

  PokemonStruct = Struct.new(:pokemon_id, :current_hp, :status_condition, :type1_id, :type2_id, :move1_id, :move2_id, :move3_id, :move4_id, :max_hp, :level, :nickname, keyword_init: true)

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

  def get_pokemon_from_save(save_file, pokemon_offset, nickname_offset, is_party_pokemon)
    pokemon_index = save_file[pokemon_offset]
    pokemon_id = @pokemon_indexes_to_id_arr[pokemon_index - 1]
    current_hp = (save_file[pokemon_offset + 1] << 8) + save_file[pokemon_offset + 2]
    status_condition = save_file[pokemon_offset + 4]
    type1_id = save_file[pokemon_offset + 5]
    type2_id = save_file[pokemon_offset + 6]
    move1_id = save_file[pokemon_offset + 8]
    move2_id = save_file[pokemon_offset + 9]
    move3_id = save_file[pokemon_offset + 0xA]
    move4_id = save_file[pokemon_offset + 0xB]
    max_nickname_size = 0xB
    nickname = save_file[nickname_offset..nickname_offset + max_nickname_size]
    nickname = translate_game_string(nickname, @mappings)
    unless is_party_pokemon
      return PokemonStruct.new(pokemon_id: pokemon_id, current_hp: current_hp, status_condition: status_condition, type1_id: type1_id, type2_id: type2_id, move1_id: move1_id, move2_id: move2_id, move3_id: move3_id, move4_id: move4_id, nickname: nickname)

    end

    level = save_file[pokemon_offset + 0x21]
    max_hp = (save_file[pokemon_offset + 0x22] << 8) + save_file[pokemon_offset + 0x23]
    pokemon = PokemonStruct.new(pokemon_id: pokemon_id, current_hp: current_hp, status_condition: status_condition, type1_id: type1_id, type2_id: type2_id, move1_id: move1_id, move2_id: move2_id, move3_id: move3_id, move4_id: move4_id, max_hp: max_hp, level: level, nickname: nickname)

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
    # TODO: duplicated array, move this somewhere else
    # Pokemon index is different to pokemon id, see https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_(Generation_I)
    @pokemon_indexes_to_id_arr = [112, 115, 32, 35, 21, 100, 34, 80, 2, 103, 108, 102, 88, 94, 29, 31, 104, 111, 131, 59, 151, 130, 90, 72, 92, 123, 120, 9, 127, 114, -1, -1, 58, 95, 22, 16, 79, 64, 75, 113, 67, 122, 106, 107, 24, 47, 54, 96, 76, -1, 126, -1, 125, 82, 109, -1, 56, 86, 50, 128, -1, -1, -1, 83, 48, 149, -1, -1, -1, 84, 60, 124, 146, 144, 145, 132, 52, 98, -1, -1, -1, 37, 38, 25, 26, -1, -1, 147, 148, 140, 141, 116, 117, -1, -1, 27, 28, 138, 139, 39, 40, 133, 136, 135, 134, 66, 41, 23, 46, 61, 62, 13, 14, 15, -1, 85, 57, 51, 49, 87, -1, -1, 10, 11, 12, 68, -1, 55, 97, 42, 150, 143, 129, -1, -1, 89, -1, 99, 91, -1, 101, 36, 110, 53, 105, -1, 93, 63, 65, 17, 18, 121, 1, 3, 73, -1, 118, 119, -1, -1, -1, -1, 77, 78, 19, 20, 33, 30, 74, 137, 142, -1, 81, -1, -1, 4, 7, 5, 8, 6, -1, -1, -1, -1, 43, 44, 45, 69, 70, 71]
    (0..party_size - 1).each do |i|
      nickname_offset = nicknames_offset + (i * max_nickname_size)
      pokemon = get_pokemon_from_save(save_file, pokemon_offset, nickname_offset, true)
      party_pokemon.push(pokemon)
      pokemon_offset += pokemon_size
    end

    party_pokemon
  end

  def get_badges_obtained(save_file)
    gym_badges_offset = 0x2602
    # Each bit is a badge, MSB to LSB is Boulder, Cascade, Thunder, Rainbow, Soul, Marsh, Volcano, Earth.
    badges_bit_field = save_file[gym_badges_offset]
    obtained_badges = []
    obtained_badges.push("Boulder") if (badges_bit_field >> 0 & 0x1) != 0
    obtained_badges.push("Cascade") if (badges_bit_field >> 1 & 0x1) != 0
    obtained_badges.push("Thunder") if (badges_bit_field >> 2 & 0x1) != 0
    obtained_badges.push("Rainbow") if (badges_bit_field >> 3 & 0x1) != 0
    obtained_badges.push("Soul") if (badges_bit_field >> 4 & 0x1) != 0
    obtained_badges.push("Marsh") if (badges_bit_field >> 5 & 0x1) != 0
    obtained_badges.push("Volcano") if (badges_bit_field >> 6 & 0x1) != 0
    obtained_badges.push("Earth") if (badges_bit_field >> 0 & 0x1) != 0
  end

  def get_playtime_in_seconds(save_file)
    playtime_offset = 0x2CED
    playtime_hours = save_file[playtime_offset]
    playtime_minutes = save_file[playtime_offset + 2]
    playtime_seconds = save_file[playtime_offset + 3]
    (playtime_hours * 60 * 60) + (playtime_minutes * 60) + playtime_seconds
  end

  def get_hall_of_fame_entries(save_file)
    hall_of_fame_offset = 0x0598
    max_hall_of_fame_record_count = 50
    pokemon_size = 16
    max_pokemon_per_record = 6
    hall_of_fame_entries = []
    max_nickname_size = 0xB # TODO: This is defined in multiple places, refactor
    pokemon_padding_size = 0x3

    @pokemon_indexes_to_id_arr = [112, 115, 32, 35, 21, 100, 34, 80, 2, 103, 108, 102, 88, 94, 29, 31, 104, 111, 131, 59, 151, 130, 90, 72, 92, 123, 120, 9, 127, 114, -1, -1, 58, 95, 22, 16, 79, 64, 75, 113, 67, 122, 106, 107, 24, 47, 54, 96, 76, -1, 126, -1, 125, 82, 109, -1, 56, 86, 50, 128, -1, -1, -1, 83, 48, 149, -1, -1, -1, 84, 60, 124, 146, 144, 145, 132, 52, 98, -1, -1, -1, 37, 38, 25, 26, -1, -1, 147, 148, 140, 141, 116, 117, -1, -1, 27, 28, 138, 139, 39, 40, 133, 136, 135, 134, 66, 41, 23, 46, 61, 62, 13, 14, 15, -1, 85, 57, 51, 49, 87, -1, -1, 10, 11, 12, 68, -1, 55, 97, 42, 150, 143, 129, -1, -1, 89, -1, 99, 91, -1, 101, 36, 110, 53, 105, -1, 93, 63, 65, 17, 18, 121, 1, 3, 73, -1, 118, 119, -1, -1, -1, -1, 77, 78, 19, 20, 33, 30, 74, 137, 142, -1, 81, -1, -1, 4, 7, 5, 8, 6, -1, -1, -1, -1, 43, 44, 45, 69, 70, 71]
    (0..max_hall_of_fame_record_count).each do |i|
      current_offset = hall_of_fame_offset + (pokemon_size * 6 * i)
      # Padding seems to only exist if there is a pokemon in the hall of fame entry. We break if there is no padding (no hall of fame entry)
      has_padding = save_file[current_offset + 1 + max_nickname_size + 1..current_offset + 1 + max_nickname_size + pokemon_padding_size].sum.zero?
      break unless has_padding

      hall_of_fame_entries.push([])
      (0..max_pokemon_per_record - 1).each do |j|
        pokemon_offset = current_offset + (j * pokemon_size)
        pokemon_index = save_file[pokemon_offset]
        next if pokemon_index.zero? || pokemon_index == 0xFF

        pokemon_id = @pokemon_indexes_to_id_arr[pokemon_index - 1]

        level = save_file[pokemon_offset + 1]
        nickname = save_file[pokemon_offset + 2..pokemon_offset + 2 + max_nickname_size]
        nickname = translate_game_string(nickname, @mappings)
        pokemon = PokemonStruct.new(pokemon_id: pokemon_id, level: level, nickname: nickname)
        pokemons = hall_of_fame_entries[i]
        pokemons.push(pokemon)
      end
    end
    hall_of_fame_entries
  end

  def get_current_box_pokemon(save_file)
    pokemon_box_offset = 0x30C0
    pokemon_size = 0x21
    max_pokemon_in_a_box = 20
    max_nickname_size = 0xB
    nicknames_offset = pokemon_box_offset + 0x386

    box_pokemon = []
    pokemon_count = save_file[pokemon_box_offset]
    return box_pokemon if pokemon_count.zero?

    (0..pokemon_count - 1).each do |i|
      pokemon_data_offset = pokemon_box_offset + 0x16 + (i * pokemon_size)
      nickname_offset = nicknames_offset + (i * max_nickname_size)
      pokemon = get_pokemon_from_save(save_file, pokemon_data_offset, nickname_offset, false)
      box_pokemon.push(pokemon)
    end

    box_pokemon
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
    # TODO: Either disable edit or rerun create logic on an edit (since it's just uploading a file again)
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

    selected_game = params[:gen1_game]
    @gen1_entry.game = selected_game
    if not @gen1_entry.valid?
      render :new
      return
    end

    uploaded_file = File.binread(params[:gen1_entry][:saveFile])
    player_name = translate_game_string(get_player_name(uploaded_file), @mappings)
    @gen1_entry.playerName = player_name

    party_pokemon = get_player_party(uploaded_file.bytes)
    party = Party.create(gen1_entry: @gen1_entry)
    party_pokemon.each do |pokemon|
      # TODO: Change type column to type_id
      created_pokemon = Pokemon.create(party: party, pokemon_id: pokemon.pokemon_id, current_hp: pokemon.current_hp, status_condition: pokemon.status_condition, type1: pokemon.type1_id, type2: pokemon.type2_id, move1_id: pokemon.move1_id, move2_id: pokemon.move2_id, move3_id: pokemon.move3_id, move4_id: pokemon.move4_id, max_hp: pokemon.max_hp, level: pokemon.level, nickname: pokemon.nickname)
      party.pokemons.push(created_pokemon)
    end

    obtained_badges = get_badges_obtained(uploaded_file.bytes)
    @gen1_entry.badges = obtained_badges

    playtime = get_playtime_in_seconds(uploaded_file.bytes)
    @gen1_entry.playtime = playtime

    hall_of_fame_entries = get_hall_of_fame_entries(uploaded_file.bytes)
    hall_of_fame_entries.each do |entry|
      hall_of_fame_entry = Gen1HallOfFameEntry.create(gen1_entry: @gen1_entry)
      entry.each do |pokemon|
        created_pokemon = Gen1HallOfFamePokemon.create(pokemon_id: pokemon.pokemon_id, level: pokemon.level, nickname: pokemon.nickname)
        hall_of_fame_entry.gen1_hall_of_fame_pokemons.push(created_pokemon)
      end
    end

    current_box_pokemon = get_current_box_pokemon(uploaded_file.bytes)
    current_box = Gen1Box.create(gen1_entry: @gen1_entry)
    current_box_pokemon.each do |pokemon|
      # TODO: Level and max hp can be calculated for box pokemon. See https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_I)
      created_pokemon = Pokemon.create(gen1_box: current_box, pokemon_id: pokemon.pokemon_id, current_hp: pokemon.current_hp, status_condition: pokemon.status_condition, type1: pokemon.type1_id, type2: pokemon.type2_id, move1_id: pokemon.move1_id, move2_id: pokemon.move2_id, move3_id: pokemon.move3_id, move4_id: pokemon.move4_id, nickname: pokemon.nickname)
      current_box.pokemons.push(created_pokemon)
    end

    # Baseline: Player name, each pokemon in party, gyms completed, each pokemon in boxes, time played, hall of fame, daycare?
    # TODO Status condition for pokemon
    # https://bulbapedia.bulbagarden.net/wiki/Pok%C3%A9mon_data_structure_(Generation_I)
    # Potentially different offsets for different pokemon gen 1 versions (red, blue, yellow). Just stick with red for now
    #
    # TODO: On cascade delete things for pokemon + party + gen1 hall of fame etc

    # TODO: Can't get what game it is from the savefile, will need to have user input (dropdown?)
    # TODO: pokemon red and blue are identical, so only pokemon red/blue then yellow need to be pickable values
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
    params.require(:gen1_entry).permit(:saveFile, :gen1_game)
  end
end
