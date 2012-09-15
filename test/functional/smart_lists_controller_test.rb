require 'test_helper'

class SmartListsControllerTest < ActionController::TestCase
  setup do
    @smart_list = smart_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create smart_list" do
    assert_difference('SmartList.count') do
      post :create, smart_list: @smart_list.attributes
    end

    assert_redirected_to smart_list_path(assigns(:smart_list))
  end

  test "should show smart_list" do
    get :show, id: @smart_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @smart_list
    assert_response :success
  end

  test "should update smart_list" do
    put :update, id: @smart_list, smart_list: @smart_list.attributes
    assert_redirected_to smart_list_path(assigns(:smart_list))
  end

  test "should destroy smart_list" do
    assert_difference('SmartList.count', -1) do
      delete :destroy, id: @smart_list
    end

    assert_redirected_to smart_lists_path
  end
end
