class Gen2EntriesController < ApplicationController
  before_action :set_gen2_entry, only: %i[ show edit update destroy ]

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

  def get_player_name(save_file)
    player_name_offset = 0x200B
    player_name_max_size = 0xB
    save_file[player_name_offset..(player_name_offset + player_name_max_size)].bytes
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

    uploaded_file = File.binread(params[:gen2_entry][:save_file])
    player_name = translate_game_string(get_player_name(uploaded_file), @mappings)

    @gen2_entry.player_name = player_name

    # TODO: Possible to have different offsets from gold/silver to crystal, will need to handle

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
