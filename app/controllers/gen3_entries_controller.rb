class Gen3EntriesController < ApplicationController
  before_action :set_gen3_entry, only: %i[ show edit update destroy ]

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

  def get_player_name(save_file)
    # TODO
  end

  def translate_game_string(string, mappings)
    # TODO
  end

  # POST /gen3_entries or /gen3_entries.json
  def create
    @gen3_entry = Gen3Entry.new(gen3_entry_params)

    # TODO: We have ruby sapphire emerald, and fire red, leaf green. a lot of different offsets
    # Focusing on ruby + sapphire for now

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
