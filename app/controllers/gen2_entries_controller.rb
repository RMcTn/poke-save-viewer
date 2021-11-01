class Gen2EntriesController < ApplicationController
  require "active_support"
  include ActiveSupport::NumberHelper
  before_action :set_gen2_entry, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  before_action :is_user_authorized?, except: [:index, :create, :new]

  @@max_pokemon_in_party = 6

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

  # POST /gen2_entries or /gen2_entries.json
  def create
    @gen2_entry = Gen2Entry.new(gen2_entry_params)

    @gen2_entry.user = current_user

    # TODO Graphics for badges

    gen2_save_file_size = 32816
    if params[:gen2_entry][:save_file].size > gen2_save_file_size
      @gen2_entry.errors.add :base, :file_too_big, message: "File is too large. Generation 2 save files are #{number_to_human_size(gen2_save_file_size)}"
      render :new
      return
    end

    if params[:gen2_entry][:save_file].size < gen2_save_file_size
      @gen2_entry.errors.add :base, :file_too_small, message: "File is too small. Generation 2 save files are #{number_to_human_size(gen2_save_file_size)}"
      render :new
      return
    end

    uploaded_file = File.binread(params[:gen2_entry][:save_file])
    game = ""
    if @gen2_entry.is_valid_gold_silver_party?(uploaded_file.bytes)
      game = "gold/silver"
    end

    if @gen2_entry.is_valid_crystal_party?(uploaded_file.bytes)
      game = "crystal"
    end

    @gen2_entry.game = game
    if not @gen2_entry.valid?
      render :new
      return
    end

    # TODO: Populate the mapping only once
    @character_mapping = Hash.new
    File.readlines("gen1_english_mappings.txt").each do |line|
      splits = line.split(' ')
      poke_char = splits[1].to_i(16)
      @character_mapping[poke_char] = splits[0]
    end

    player_name = @gen2_entry.get_translated_player_name(uploaded_file.bytes, @character_mapping)
    @gen2_entry.player_name = player_name

    playtime = @gen2_entry.get_playtime_in_seconds(uploaded_file.bytes)
    @gen2_entry.playtime = playtime

    party_pokemon = @gen2_entry.get_player_party(uploaded_file.bytes, @character_mapping)

    johto_badges = @gen2_entry.get_johto_badges(uploaded_file.bytes)
    @gen2_entry.johto_badges = johto_badges

    kanto_badges = @gen2_entry.get_kanto_badges(uploaded_file.bytes)
    @gen2_entry.kanto_badges = kanto_badges

    if party_pokemon.size > @@max_pokemon_in_party
      @gen2_entry.errors.add :base, :too_many_pokemon, message: "Too many pokemon in party. Is this file a valid Gold/Silver or Crystal save file?"
      render :new
      return
    end

    party = Gen2Party.create(gen2_entry: @gen2_entry)
    party_pokemon.each do |pokemon|
      created_pokemon = Gen2Pokemon.create(gen2_party: party, pokemon_id: pokemon.pokemon_id, current_hp: pokemon.current_hp, status_condition: pokemon.status_condition, type1: pokemon.type1_id, type2: pokemon.type2_id, move1_id: pokemon.move1_id, move2_id: pokemon.move2_id, move3_id: pokemon.move3_id, move4_id: pokemon.move4_id, max_hp: pokemon.max_hp, level: pokemon.level, nickname: pokemon.nickname, is_shiny: pokemon.is_shiny)
      party.gen2_pokemons.push(created_pokemon)
    end

    hall_of_fame_entries = @gen2_entry.get_hall_of_fame_entries(uploaded_file.bytes, @character_mapping)
    hall_of_fame_entries.each do |entry|
      hall_of_fame_entry = Gen2HallOfFameEntry.create(gen2_entry: @gen2_entry)
      entry.each do |pokemon|
        created_pokemon = Gen2HallOfFamePokemon.create(pokemon_id: pokemon.pokemon_id, level: pokemon.level, nickname: pokemon.nickname)
        hall_of_fame_entry.gen2_hall_of_fame_pokemons.push(created_pokemon)
      end
    end

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

  def is_user_authorized?
    render file: "#{Rails.root}/public/404.html" , status: 404 if current_user != @gen2_entry.user
  end
end
