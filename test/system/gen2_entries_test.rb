require "application_system_test_case"

class Gen2EntriesTest < ApplicationSystemTestCase
  setup do
    @gen2_entry = gen2_entries(:one)
  end

  test "visiting the index" do
    visit gen2_entries_url
    assert_selector "h1", text: "Gen2 Entries"
  end

  test "creating a Gen2 entry" do
    visit gen2_entries_url
    click_on "New Gen2 Entry"

    click_on "Create Gen2 entry"

    assert_text "Gen2 entry was successfully created"
    click_on "Back"
  end

  test "updating a Gen2 entry" do
    visit gen2_entries_url
    click_on "Edit", match: :first

    click_on "Update Gen2 entry"

    assert_text "Gen2 entry was successfully updated"
    click_on "Back"
  end

  test "destroying a Gen2 entry" do
    visit gen2_entries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Gen2 entry was successfully destroyed"
  end
end
