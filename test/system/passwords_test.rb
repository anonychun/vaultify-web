require "application_system_test_case"

class PasswordsTest < ApplicationSystemTestCase
  setup do
    @password = passwords(:one)
  end

  test "visiting the index" do
    visit passwords_url
    assert_selector "h1", text: "Passwords"
  end

  test "should create password" do
    visit passwords_url
    click_on "New password"

    fill_in "Password", with: @password.password
    fill_in "Url", with: @password.url
    fill_in "Username", with: @password.username
    click_on "Create Password"

    assert_text "Password was successfully created"
    click_on "Back"
  end

  test "should update Password" do
    visit password_url(@password)
    click_on "Edit this password", match: :first

    fill_in "Password", with: @password.password
    fill_in "Url", with: @password.url
    fill_in "Username", with: @password.username
    click_on "Update Password"

    assert_text "Password was successfully updated"
    click_on "Back"
  end

  test "should destroy Password" do
    visit password_url(@password)
    click_on "Destroy this password", match: :first

    assert_text "Password was successfully destroyed"
  end
end
