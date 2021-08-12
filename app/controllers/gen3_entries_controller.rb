class Gen3EntriesController < ApplicationController
  before_action :set_gen3_entry, only: %i[ show edit update destroy ]

  def translate_game_string(game_str, character_mapping)
    translated_string = ""
    terminating_character = 0xFF
    game_str.each do |byte|
      return translated_string if (byte == '0') || (byte == terminating_character)

      mapped_character = character_mapping[byte]
      translated_string += mapped_character unless mapped_character.nil?
    end
    translated_string
  end

  def get_player_name(save_file)
    player_name_offset = 0x2000
    player_name_max_size = 0x7
    save_file[player_name_offset..(player_name_offset + player_name_max_size)].bytes
  end

  # GET /gen3_entries or /gen3_entries.json
  def index
    @gen3_entries = Gen3Entry.all
  end

  # GET /gen3_entries/1 or /gen3_entries/1.json
  def show
  end

  # GET /gen3_entries/new
  def new
    @gen3_entry = Gen3Entry.new
  end

  # GET /gen3_entries/1/edit
  def edit
  end

  # POST /gen3_entries or /gen3_entries.json
  def create
    @gen3_entry = Gen3Entry.new(gen3_entry_params)

    # TODO: We have ruby sapphire emerald, and fire red, leaf green. a lot of different offsets
    # Focusing on ruby + sapphire for now
    #
    # TODO: NOTE: Wiki says save has a game code to tell apart the game https://bulbapedia.bulbagarden.net/wiki/Save_data_structure_(Generation_III)
    @mappings = Hash.new
    File.readlines("gen3_english_mappings.txt").each do |line|
      splits = line.split(' ')
      poke_char = splits[1].to_i(16)
      ## TODO Check what the unicode values are like
      @mappings[poke_char] = splits[0]
    end

    uploaded_file = File.binread(params[:gen3_entry][:save_file])
    player_name = translate_game_string(get_player_name(uploaded_file), @mappings)

    @gen3_entry.player_name = player_name

    respond_to do |format|
      if @gen3_entry.save
        format.html { redirect_to @gen3_entry, notice: "Gen3 entry was successfully created." }
        format.json { render :show, status: :created, location: @gen3_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gen3_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gen3_entries/1 or /gen3_entries/1.json
  def update
    respond_to do |format|
      if @gen3_entry.update(gen3_entry_params)
        format.html { redirect_to @gen3_entry, notice: "Gen3 entry was successfully updated." }
        format.json { render :show, status: :ok, location: @gen3_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gen3_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gen3_entries/1 or /gen3_entries/1.json
  def destroy
    @gen3_entry.destroy
    respond_to do |format|
      format.html { redirect_to gen3_entries_url, notice: "Gen3 entry was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gen3_entry
    @gen3_entry = Gen3Entry.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def gen3_entry_params
    params.require(:gen3_entry).permit(:save_file)
  end
end
