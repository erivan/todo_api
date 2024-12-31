module AuthenticationHelpers
  def sign_in_user(user)
    post user_session_path params: { user: { email: user.email, password: user.password } }

    response.headers['Authorization']
  end
end
