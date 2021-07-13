require "test_helper"

class Gen1EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gen1_entry = gen1_entries(:one)
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
      post gen1_entries_url, params: { gen1_entry: { playerName: @gen1_entry.playerName } }
    end

    assert_redirected_to gen1_entry_url(Gen1Entry.last)
  end

  test "should show gen1_entry" do
    get gen1_entry_url(@gen1_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_gen1_entry_url(@gen1_entry)
    assert_response :success
  end

  test "should update gen1_entry" do
    patch gen1_entry_url(@gen1_entry), params: { gen1_entry: { playerName: @gen1_entry.playerName } }
    assert_redirected_to gen1_entry_url(@gen1_entry)
  end

  test "should destroy gen1_entry" do
    assert_difference('Gen1Entry.count', -1) do
      delete gen1_entry_url(@gen1_entry)
    end

    assert_redirected_to gen1_entries_url
  end
end
