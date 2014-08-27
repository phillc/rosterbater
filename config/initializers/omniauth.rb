Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo, APP_CONFIG[:yahoo][:key], APP_CONFIG[:yahoo][:secret]
end
