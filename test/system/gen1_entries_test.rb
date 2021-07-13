require "application_system_test_case"

class Gen1EntriesTest < ApplicationSystemTestCase
  setup do
    @gen1_entry = gen1_entries(:one)
  end

  test "visiting the index" do
    visit gen1_entries_url
    assert_selector "h1", text: "Gen1 Entries"
  end

  test "creating a Gen1 entry" do
    visit gen1_entries_url
    click_on "New Gen1 Entry"

    fill_in "Playername", with: @gen1_entry.playerName
    click_on "Create Gen1 entry"

    assert_text "Gen1 entry was successfully created"
    click_on "Back"
  end

  test "updating a Gen1 entry" do
    visit gen1_entries_url
    click_on "Edit", match: :first

    fill_in "Playername", with: @gen1_entry.playerName
    click_on "Update Gen1 entry"

    assert_text "Gen1 entry was successfully updated"
    click_on "Back"
  end

  test "destroying a Gen1 entry" do
    visit gen1_entries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Gen1 entry was successfully destroyed"
  end
end
