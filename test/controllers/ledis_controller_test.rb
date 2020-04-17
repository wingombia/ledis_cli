require 'test_helper'

class LedisControllerTest < ActionDispatch::IntegrationTest
  test "should get cli" do
    get ledis_cli_url
    assert_response :success
  end

end
