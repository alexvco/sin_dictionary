helpers do
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    session[:user_id].present?
  end

# Define the condition
  set(:authenticate_user) do |val|
    condition do
      if val 
        redirect '/users/sign_in' if !logged_in?
      end
    end
  end

end 