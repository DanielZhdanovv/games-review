# config/initializers/auth0.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    ENV['AUTH0_CLIENT_ID'],
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    {
      callback_path: '/auth/auth0/callback',
      callback_url: ENV['AUTH0_CALLBACK_URL'],
      authorize_params: {
        scope: 'openid email profile'
      }
    }
  )
end

OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true