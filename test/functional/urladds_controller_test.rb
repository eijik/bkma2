require File.dirname(__FILE__) + '/../test_helper'

class UrladdsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:urladds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_urladd
    assert_difference('Urladd.count') do
      post :create, :urladd => { }
    end

    assert_redirected_to urladd_path(assigns(:urladd))
  end

  def test_should_show_urladd
    get :show, :id => urladds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => urladds(:one).id
    assert_response :success
  end

  def test_should_update_urladd
    put :update, :id => urladds(:one).id, :urladd => { }
    assert_redirected_to urladd_path(assigns(:urladd))
  end

  def test_should_destroy_urladd
    assert_difference('Urladd.count', -1) do
      delete :destroy, :id => urladds(:one).id
    end

    assert_redirected_to urladds_path
  end
end
