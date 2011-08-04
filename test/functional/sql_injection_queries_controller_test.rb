require 'test_helper'

class SqlInjectionQueriesControllerTest < ActionController::TestCase
  setup do
    @sql_injection_query = sql_injection_queries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sql_injection_queries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sql_injection_query" do
    assert_difference('SqlInjectionQuery.count') do
      post :create, :sql_injection_query => @sql_injection_query.attributes
    end

    assert_redirected_to sql_injection_query_path(assigns(:sql_injection_query))
  end

  test "should show sql_injection_query" do
    get :show, :id => @sql_injection_query.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sql_injection_query.to_param
    assert_response :success
  end

  test "should update sql_injection_query" do
    put :update, :id => @sql_injection_query.to_param, :sql_injection_query => @sql_injection_query.attributes
    assert_redirected_to sql_injection_query_path(assigns(:sql_injection_query))
  end

  test "should destroy sql_injection_query" do
    assert_difference('SqlInjectionQuery.count', -1) do
      delete :destroy, :id => @sql_injection_query.to_param
    end

    assert_redirected_to sql_injection_queries_path
  end
end
