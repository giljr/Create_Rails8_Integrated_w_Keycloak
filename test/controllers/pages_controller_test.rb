require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get public" do
    get pages_public_url
    assert_response :success
  end

  test "should get secured" do
    get pages_secured_url
    assert_response :success
  end

  test "should get admin" do
    get pages_admin_url
    assert_response :success
  end
end
