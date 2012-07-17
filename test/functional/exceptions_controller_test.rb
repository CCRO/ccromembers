require 'test_helper'

class ExceptionsControllerTest < ActionController::TestCase
  test "should get accessdenied" do
    get :accessdenied
    assert_response :success
  end

end
