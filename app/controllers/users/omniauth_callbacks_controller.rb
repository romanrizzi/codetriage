# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = GitHubAuthenticator.authenticate(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = if @user.valid_email?
                         I18n.t "devise.omniauth_callbacks.success", kind: "GitHub"
                       else
                         I18n.t "devise.omniauth_callbacks.bad_email_success", kind: "GitHub"
                       end

      redirect_authenticated_user(@user)
    else
      session["devise.github_data"] = request.env["omniauth.auth"].delete("extra")
      flash[:error]  = no_email_error if request.env["omniauth.auth"].info.email.blank?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.failure",
                              kind: "GitHub", reason: "Invalid credentials" if flash[:error].blank?
      redirect_to root_path
    end
  end

  private

  def redirect_authenticated_user(authenticated_user)
    if authenticated_user.should_select_languages?
      sign_in authenticated_user
      redirect_to user_languages_path(authenticated_user), event: :authentication
    else
      sign_in_and_redirect authenticated_user, event: :authentication
    end
  end

  def no_email_error
    msg =  "You need a public email address on GitHub to sign up you can add"
    msg << " an email, sign up for triage, then remove it from GitHub:<hr />"
    msg << "<a href='https://github.com/settings/profile'>GitHub Profile</a>"
    msg.html_safe
  end
end
