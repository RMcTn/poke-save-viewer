require "test_helper"

class Gen2EntriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:user_no_gen2_entries)
    @save_file_gold = fixture_file_upload("Gold - Poison.sav", "application/octet-stream", true)
    @save_file_crystal = fixture_file_upload("Crystal.sav", "application/octet-stream", true)
    @large_file = fixture_file_upload("gen2 large.sav", "application/octet-stream", true)
    @small_file = fixture_file_upload("gen2 small.sav", "application/octet-stream", true)
  end

  test "should require login to view index" do
    sign_out :user
    get gen2_entries_url
    assert_response :redirect
  end

  test "should require login to view new" do
    sign_out :user
    get new_gen2_entry_url
    assert_response :redirect
  end

  test "should require login to view entry" do
    post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    sign_out :user
    get gen2_entry_url(Gen2Entry.last)
    assert_response :redirect
  end

  test "user A should not be able to view user B's entries" do
    post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    sign_out :user
    sign_in users(:user_no_gen2_entries2)
    get gen2_entry_url(Gen2Entry.last)
    assert_response :missing
  end

  test "user A should not be able to edit user B's entries" do
    post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    sign_out :user
    sign_in users(:user_no_gen2_entries2)
    get edit_gen2_entry_url(Gen2Entry.last)
    assert_response :missing
  end

  test "should get index" do
    get gen2_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_gen2_entry_url
    assert_response :success
  end

  test "should create gen2_entry" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end

    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should show gen2_entry" do
    post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    get gen2_entry_url(Gen2Entry.last)
    assert_response :success
  end

  test "should recognise gold game for gen2_entry" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    assert_equal("gold/silver", Gen2Entry.last.game)
    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should recognise crystal game for gen2_entry" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_crystal } }
    end
    assert_equal("crystal", Gen2Entry.last.game)
    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should get translated playername from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    assert_equal("Zest", Gen2Entry.last.player_name)
    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should get playtime from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    assert_equal(227_743, Gen2Entry.last.playtime)

    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should get party pokemon from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    pokemons = [
      Gen2Pokemon.new(pokemon_id: 73, current_hp: 186, status_condition: 0, type1: 21, type2: 3, move1_id: 57, move2_id: 51, move3_id: 48, move4_id: 196, max_hp: 186, level: 60, nickname: "Mera", is_shiny: true),
      Gen2Pokemon.new(pokemon_id: 93, current_hp: 137, status_condition: 0, type1: 8, type2: 3, move1_id: 95, move2_id: 109, move3_id: 138, move4_id: 171, max_hp: 137, level: 55, nickname: "Johnny", is_shiny: false),
      Gen2Pokemon.new(pokemon_id: 31, current_hp: 205, status_condition: 0, type1: 3, type2: 4, move1_id: 24, move2_id: 70, move3_id: 44, move4_id: 156, max_hp: 205, level: 60, nickname: "Jennifer", is_shiny: false),
      Gen2Pokemon.new(pokemon_id: 169, current_hp: 199, status_condition: 0, type1: 3, type2: 2, move1_id: 19, move2_id: 109, move3_id: 44, move4_id: 216, max_hp: 199, level: 60, nickname: "Bruce", is_shiny: true),
      Gen2Pokemon.new(pokemon_id: 49, current_hp: 174, status_condition: 0, type1: 7, type2: 3, move1_id: 60, move2_id: 127, move3_id: 188, move4_id: 48, max_hp: 174, level: 60, nickname: "Jack", is_shiny: false),
      Gen2Pokemon.new(pokemon_id: 34, current_hp: 179, status_condition: 0, type1: 3, type2: 4, move1_id: 70, move2_id: 247, move3_id: 24, move4_id: 231, max_hp: 179, level: 60, nickname: "Hank", is_shiny: true),
    ]
    party = Gen2Entry.last.gen2_party

    assert_equal(6, party.gen2_pokemons.size)

    (0..party.gen2_pokemons.size - 1).each do |i|
      assert(party.gen2_pokemons[i].same_as_pokemon?(pokemons[i]), "Expected index #{i} pokemon to be #{pokemons[i].attributes}, actual was #{party.gen2_pokemons[i].attributes}")
    end
  end

  test "should get hall of fame entries from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end

    hall_of_fame_entries = Gen2Entry.last.gen2_hall_of_fame_entries
    hall_of_fame_entry_first_pokemons = [
      Gen2HallOfFamePokemon.new(pokemon_id: 73, nickname: "Mera", level: 60),
      Gen2HallOfFamePokemon.new(pokemon_id: 93, nickname: "Johnny", level: 55),
      Gen2HallOfFamePokemon.new(pokemon_id: 31, nickname: "Jennifer", level: 60),
      Gen2HallOfFamePokemon.new(pokemon_id: 169, nickname: "Bruce", level: 60),
      Gen2HallOfFamePokemon.new(pokemon_id: 49, nickname: "Jack", level: 60),
      Gen2HallOfFamePokemon.new(pokemon_id: 34, nickname: "Hank", level: 60)
    ]
    assert(hall_of_fame_entries.size == 2)
    hall_of_fame_entries.first.gen2_hall_of_fame_pokemons
    hall_of_fame_entries.first.gen2_hall_of_fame_pokemons.each_with_index do |pokemon, i|
      assert(pokemon.same_as_pokemon?(hall_of_fame_entry_first_pokemons[i]), "Expected index #{i} pokemon to be #{hall_of_fame_entry_first_pokemons[i].attributes}, actual was #{pokemon.attributes}")
    end

    hall_of_fame_entry_second_pokemons = [
      Gen2HallOfFamePokemon.new(pokemon_id: 93, nickname: "Johnny", level: 47),
      Gen2HallOfFamePokemon.new(pokemon_id: 31, nickname: "Jennifer", level: 47),
      Gen2HallOfFamePokemon.new(pokemon_id: 73, nickname: "Mera", level: 51),
      Gen2HallOfFamePokemon.new(pokemon_id: 169, nickname: "Bruce", level: 51),
      Gen2HallOfFamePokemon.new(pokemon_id: 49, nickname: "Jack", level: 47),
      Gen2HallOfFamePokemon.new(pokemon_id: 34, nickname: "Hank", level: 48)
    ]

    hall_of_fame_entries.second.gen2_hall_of_fame_pokemons.each_with_index do |pokemon, i|
      assert(pokemon.same_as_pokemon?(hall_of_fame_entry_second_pokemons[i]), "Expected index #{i} pokemon to be #{hall_of_fame_entry_second_pokemons[i].attributes}, actual was #{pokemon.attributes}")
    end
  end

  test "should get johto badges from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    assert_equal(["Zephyr", "Plain", "Fog", "Storm", "Mineral", "Glacier", "Rising"], Gen2Entry.last.johto_badges)
  end

  test "should get kanto badges from gen2 gold save" do
    assert_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @save_file_gold } }
    end
    assert_equal(["Boulder", "Thunder", "Rainbow", "Soul", "Marsh", "Volcano", "Earth"], Gen2Entry.last.kanto_badges)
  end

  test "should error if file is too big" do
    assert_no_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @large_file } }
    end

  end

  test "should error if file is too small" do
    assert_no_difference('Gen2Entry.count') do
      post gen2_entries_url, params: { gen2_entry: { save_file: @small_file } }
    end

  end

end
