require "test_helper"

class Gen3EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gen3_entry = gen3_entries(:one)
  end

  test "should get index" do
    get gen3_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_gen3_entry_url
    assert_response :success
  end

  test "should create gen3_entry" do
    assert_difference('Gen3Entry.count') do
      post gen3_entries_url, params: { gen3_entry: {  } }
    end

    assert_redirected_to gen3_entry_url(Gen3Entry.last)
  end

  test "should show gen3_entry" do
    get gen3_entry_url(@gen3_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_gen3_entry_url(@gen3_entry)
    assert_response :success
  end

  test "should update gen3_entry" do
    patch gen3_entry_url(@gen3_entry), params: { gen3_entry: {  } }
    assert_redirected_to gen3_entry_url(@gen3_entry)
  end

  test "should destroy gen3_entry" do
    assert_difference('Gen3Entry.count', -1) do
      delete gen3_entry_url(@gen3_entry)
    end

    assert_redirected_to gen3_entries_url
  end
end
