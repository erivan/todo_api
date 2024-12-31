Rails.application.config.tap do |config|
  config.devise_jwt_secret_key = ENV.fetch("DEVISE_JWT_SECRET_KEY")
end
