require 'test_helper'

class SqlInjectionControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
