require 'test_helper'

class SiteContentsControllerTest < ActionController::TestCase
  setup do
    @site_content = site_contents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:site_contents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site_content" do
    assert_difference('SiteContent.count') do
      post :create, :site_content => @site_content.attributes
    end

    assert_redirected_to site_content_path(assigns(:site_content))
  end

  test "should show site_content" do
    get :show, :id => @site_content.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @site_content.to_param
    assert_response :success
  end

  test "should update site_content" do
    put :update, :id => @site_content.to_param, :site_content => @site_content.attributes
    assert_redirected_to site_content_path(assigns(:site_content))
  end

  test "should destroy site_content" do
    assert_difference('SiteContent.count', -1) do
      delete :destroy, :id => @site_content.to_param
    end

    assert_redirected_to site_contents_path
  end
end
