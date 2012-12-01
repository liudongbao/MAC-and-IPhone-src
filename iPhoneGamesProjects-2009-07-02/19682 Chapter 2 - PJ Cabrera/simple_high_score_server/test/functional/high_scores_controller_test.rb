require 'test_helper'

class HighScoresControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:high_scores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create high_score" do
    assert_difference('HighScore.count') do
      post :create, :high_score => { }
    end

    assert_redirected_to high_score_path(assigns(:high_score))
  end

  test "should show high_score" do
    get :show, :id => high_scores(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => high_scores(:one).id
    assert_response :success
  end

  test "should update high_score" do
    put :update, :id => high_scores(:one).id, :high_score => { }
    assert_redirected_to high_score_path(assigns(:high_score))
  end

  test "should destroy high_score" do
    assert_difference('HighScore.count', -1) do
      delete :destroy, :id => high_scores(:one).id
    end

    assert_redirected_to high_scores_path
  end
end
