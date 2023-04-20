require "test_helper"

class MessagingControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get messaging_create_url
    assert_response :success
  end

  test "should get update" do
    get messaging_update_url
    assert_response :success
  end

  test "should get index" do
    get messaging_index_url
    assert_response :success
  end
end
