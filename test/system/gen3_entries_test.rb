require "application_system_test_case"

class Gen3EntriesTest < ApplicationSystemTestCase
  setup do
    @gen3_entry = gen3_entries(:one)
  end

  test "visiting the index" do
    visit gen3_entries_url
    assert_selector "h1", text: "Gen3 Entries"
  end

  test "creating a Gen3 entry" do
    visit gen3_entries_url
    click_on "New Gen3 Entry"

    click_on "Create Gen3 entry"

    assert_text "Gen3 entry was successfully created"
    click_on "Back"
  end

  test "updating a Gen3 entry" do
    visit gen3_entries_url
    click_on "Edit", match: :first

    click_on "Update Gen3 entry"

    assert_text "Gen3 entry was successfully updated"
    click_on "Back"
  end

  test "destroying a Gen3 entry" do
    visit gen3_entries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Gen3 entry was successfully destroyed"
  end
end
