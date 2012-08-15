require 'test_helper'

class PollingSessionsControllerTest < ActionController::TestCase
  setup do
    @polling_session = polling_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:polling_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create polling_session" do
    assert_difference('PollingSession.count') do
      post :create, polling_session: @polling_session.attributes
    end

    assert_redirected_to polling_session_path(assigns(:polling_session))
  end

  test "should show polling_session" do
    get :show, id: @polling_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @polling_session
    assert_response :success
  end

  test "should update polling_session" do
    put :update, id: @polling_session, polling_session: @polling_session.attributes
    assert_redirected_to polling_session_path(assigns(:polling_session))
  end

  test "should destroy polling_session" do
    assert_difference('PollingSession.count', -1) do
      delete :destroy, id: @polling_session
    end

    assert_redirected_to polling_sessions_path
  end
end
