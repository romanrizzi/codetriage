# frozen_string_literal: true

require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  test "make user feel good when legit email address" do
    stub_oauth_user('legit@legit.com')
    get :github
    assert flash[:notice] == I18n.t("devise.omniauth_callbacks.success",
                                    kind: "GitHub")

    assert_redirected_to root_path
  end

  test "redirect to user page and inform when bad e-mail address" do
    stub_oauth_user('awful e-mail address')
    get :github
    assert flash[:notice] == I18n.t("devise.omniauth_callbacks.bad_email_success",
                                    kind: "GitHub")
    assert_redirected_to root_path
  end

  test "redirect to languages page after authenticating a new user" do
    user = stub_oauth_user('legit@legit.com', new_user: true)
    get :github

    assert_redirected_to user_languages_path(user_id: user.id)
  end

  def stub_oauth_user(email, new_user: false)
    User.new(email: email, id: -1).tap do |user|
      if new_user
        user.created_at = 5.minutes.ago
        user.favorite_languages = []
      else
        user.created_at = 6.days.ago
        user.favorite_languages = ['ruby']
      end

      user.stubs(:persisted?).returns(true)
      GitHubAuthenticator.stubs(:authenticate).returns(user)
    end
  end
end
