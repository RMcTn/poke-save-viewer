class Gen1EntriesController < ApplicationController
  before_action :set_gen1_entry, only: %i[ show edit update destroy ]

  def translateGameString(gameStr, characterMapping)
    translatedString = ""
    gameStr.each_byte do |byte|
      if byte == '0'
        return translatedString
      end
      mappedCharacter = characterMapping[byte]
      if !mappedCharacter.nil?
        translatedString += mappedCharacter
      end
    end
    return translatedString
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
      pokeChar = splits[1].to_i(16)
      @mappings[pokeChar] = splits[0]
    end
    temp = File.binread(params[:gen1_entry][:saveFile])
    playerNameOffset = 0x2598
    playerNameMaxSize = 0xB
    playerName = translateGameString(temp[playerNameOffset..(playerNameOffset + playerNameMaxSize)], @mappings)
    @gen1_entry.playerName = playerName
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
