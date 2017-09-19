Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo_oauth2, APP_CONFIG[:yahoo][:key], APP_CONFIG[:yahoo][:secret], name: 'yahoo'
end
