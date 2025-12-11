class SessionsController < ApplicationController
    def new
    #Redirect to /auth/auth0 for OmniAuth
    redirect_to '/auth/auth0'
    end

  def create
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)
    
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Signed in successfully!'
    else
      redirect_to root_path, alert: 'Authentication failed'
    end
  end

  def destroy
    reset_session
    redirect_to "https://#{ENV['AUTH0_DOMAIN']}/v2/logout?" \
                "client_id=#{ENV['AUTH0_CLIENT_ID']}&" \
                "returnTo=#{ENV['AUTH0_LOGOUT_RETURN_URL']}"
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end
end