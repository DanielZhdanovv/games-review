class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  helper_method :current_user, :logged_in?
  
  private
  
  def current_user
    # For API tokens from Postman: "Bearer user-1"
    @current_user ||= user_from_api_token || user_from_session
  end
  
  def user_from_api_token
    return nil unless request.headers['Authorization'].present?
    
    token = request.headers['Authorization'].split(' ').last
    if token.start_with?('user-')
      user_id = token.split('-').last.to_i
      User.find_by(id: user_id)
    end
  end
  
  def user_from_session
    User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      render json: { error: 'Please log in first' }, status: :unauthorized
    end
  end
end