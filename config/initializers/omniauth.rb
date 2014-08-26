Rails.application.config.middleware.use OmniAuth::Builder do
  provider :yahoo, ENV['YAHOO_KEY'], ENV['YAHOO_SECRET']
end
