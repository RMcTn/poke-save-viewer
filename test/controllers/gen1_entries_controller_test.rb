require "test_helper"

class Gen1EntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_no_gen1_entries)
    @save_file_red = fixture_file_upload("Red - Poison.sav", "application/octet-stream", true)
  end

  test "should get index" do
    get gen1_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_gen1_entry_url
    assert_response :success
  end

  test "should create gen1_entry" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end

    assert_redirected_to gen1_entry_url(Gen1Entry.last)
  end

  test "should show gen1_entry" do
    post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    get gen1_entry_url(Gen1Entry.last)
    assert_response :success
  end

  test "should require game type for gen1_entry" do
    assert_no_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red } }
    end
  end

  test "should get translated playername from gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end
    assert(Gen1Entry.last.playerName == "Zest")
    assert_redirected_to gen1_entry_url(Gen1Entry.last)
  end

  test "should get playtime from gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end
    assert(Gen1Entry.last.playtime == 223_858)
    assert_redirected_to gen1_entry_url(Gen1Entry.last)
  end

  test "should get party pokemon from gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end
    pokemons = [
      Pokemon.new(pokemon_id: 89, current_hp: 257, status_condition: 0, type1: 3, type2: 3, move1_id: 34, move2_id: 92, move3_id: 104, move4_id: 156, max_hp: 257, level: 77, nickname: "Smoothie"),
      Pokemon.new(pokemon_id: 42, current_hp: 194, status_condition: 0, type1: 3, type2: 2, move1_id: 17, move2_id: 109, move3_id: 38, move4_id: 141, max_hp: 194, level: 64, nickname: "Chippy"),
      Pokemon.new(pokemon_id: 3, current_hp: 0, status_condition: 0, type1: 22, type2: 3, move1_id: 75, move2_id: 79, move3_id: 73, move4_id: 74, max_hp: 229, level: 75, nickname: "Garlic"),
      Pokemon.new(pokemon_id: 93, current_hp: 147, status_condition: 0, type1: 8, type2: 3, move1_id: 94, move2_id: 85, move3_id: 138, move4_id: 95, max_hp: 187, level: 76, nickname: "Ash"),
      Pokemon.new(pokemon_id: 16, current_hp: 36, status_condition: 0, type1: 0, type2: 2, move1_id: 16, move2_id: 28, move3_id: 98, move4_id: 19, max_hp: 36, level: 13, nickname: "FLY"),
    ]
    party = Gen1Entry.last.party

    assert(party.pokemons.size == 5, "Expected party to have 5 pokemon")

    (0..party.pokemons.size - 1).each do |i|
      assert(party.pokemons[i].same_as_pokemon?(pokemons[i]), "Expected index #{i} pokemon to be #{pokemons[i].attributes}, actual was #{party.pokemons[i].attributes}")
    end
  end

  test "should get hall of fame entries from gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end

    hall_of_fame_entries = Gen1Entry.last.gen1_hall_of_fame_entries
    hall_of_fame_entry_first_pokemons = [
      Gen1HallOfFamePokemon.new(pokemon_id: 89, nickname: "Smoothie", level: 64),
      Gen1HallOfFamePokemon.new(pokemon_id: 42, nickname: "Chippy", level: 62),
      Gen1HallOfFamePokemon.new(pokemon_id: 3, nickname: "Garlic", level: 62),
      Gen1HallOfFamePokemon.new(pokemon_id: 45, nickname: "Soup", level: 62),
      Gen1HallOfFamePokemon.new(pokemon_id: 93, nickname: "Ash", level: 63)
    ]
    assert(hall_of_fame_entries.size == 2)
    hall_of_fame_entries.first.gen1_hall_of_fame_pokemons
    hall_of_fame_entries.first.gen1_hall_of_fame_pokemons.each_with_index do |pokemon, i|
      assert(pokemon.same_as_pokemon?(hall_of_fame_entry_first_pokemons[i]), "Expected index #{i} pokemon to be #{hall_of_fame_entry_first_pokemons[i].attributes}, actual was #{pokemon.attributes}")
    end

    hall_of_fame_entry_second_pokemons = [
      Gen1HallOfFamePokemon.new(pokemon_id: 89, nickname: "Smoothie", level: 77),
      Gen1HallOfFamePokemon.new(pokemon_id: 42, nickname: "Chippy", level: 64),
      Gen1HallOfFamePokemon.new(pokemon_id: 3, nickname: "Garlic", level: 75),
      Gen1HallOfFamePokemon.new(pokemon_id: 45, nickname: "Soup", level: 77),
      Gen1HallOfFamePokemon.new(pokemon_id: 93, nickname: "Ash", level: 76),
      Gen1HallOfFamePokemon.new(pokemon_id: 16, nickname: "FLY", level: 13)
    ]

    hall_of_fame_entries.second.gen1_hall_of_fame_pokemons.each_with_index do |pokemon, i|
      assert(pokemon.same_as_pokemon?(hall_of_fame_entry_second_pokemons[i]), "Expected index #{i} pokemon to be #{hall_of_fame_entry_second_pokemons[i].attributes}, actual was #{pokemon.attributes}")
    end
  end

  test "should get kanto badges from gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end
    assert_equal(["Boulder", "Thunder", "Rainbow", "Soul", "Marsh", "Volcano", "Earth"], Gen1Entry.last.badges)
  end

  test "should get pokemon from currently selected box gen1 save" do
    assert_difference('Gen1Entry.count') do
      post gen1_entries_url, params: { gen1_entry: { saveFile: @save_file_red }, gen1_game: "red" }
    end
    # We only get the current selected box right now
    current_box_pokemon = Gen1Entry.last.gen1_boxes.first.pokemons
    box_pokemon = [
      Pokemon.new(pokemon_id: 43, current_hp: 38, status_condition: 0, type1: 22, type2: 3, move1_id: 71, move2_id: 15, move3_id: 0, move4_id: 0, nickname: "HM"),
      Pokemon.new(pokemon_id: 118, current_hp: 39, status_condition: 0, type1: 21, type2: 21, move1_id: 64, move2_id: 39, move3_id: 57, move4_id: 0, nickname: "HM"),
      Pokemon.new(pokemon_id: 130, current_hp: 70, status_condition: 0, type1: 21, type2: 2, move1_id: 70, move2_id: 33, move3_id: 44, move4_id: 57, nickname: "GYARADOS"),
      Pokemon.new(pokemon_id: 45, current_hp: 130, status_condition: 0, type1: 22, type2: 3, move1_id: 80, move2_id: 51, move3_id: 77, move4_id: 79, nickname: "Soup")
    ]
    current_box_pokemon.each_with_index do |pokemon, i|
      assert(pokemon.same_as_pokemon?(box_pokemon[i]), "Expected index #{i} pokemon to be #{box_pokemon[i].attributes}, actual was #{pokemon.attributes}")
    end
  end

end
