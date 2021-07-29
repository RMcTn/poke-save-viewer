require "test_helper"

class Gen2EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gen2_entry = gen2_entries(:one)
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
      post gen2_entries_url, params: { gen2_entry: {  } }
    end

    assert_redirected_to gen2_entry_url(Gen2Entry.last)
  end

  test "should show gen2_entry" do
    get gen2_entry_url(@gen2_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_gen2_entry_url(@gen2_entry)
    assert_response :success
  end

  test "should update gen2_entry" do
    patch gen2_entry_url(@gen2_entry), params: { gen2_entry: {  } }
    assert_redirected_to gen2_entry_url(@gen2_entry)
  end

  test "should destroy gen2_entry" do
    assert_difference('Gen2Entry.count', -1) do
      delete gen2_entry_url(@gen2_entry)
    end

    assert_redirected_to gen2_entries_url
  end
end
