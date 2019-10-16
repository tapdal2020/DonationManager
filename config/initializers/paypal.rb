# PayPal::SDK.load("config/paypal.yml", Rails.env)
PayPal::SDK::Core::Config.load('config/paypal.yml',  ENV['RACK_ENV'] || 'development')
PayPal::SDK.logger = Logger.new(STDERR)
PayPal::SDK.logger.level = Logger::INFO
# PayPal::SDK.logger = Rails.logger
