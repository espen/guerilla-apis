#\ -w -p 8765
require 'guerilla_api'

# Middleware stack shared by all apps
use Rack::Head
use Rack::ContentLength
use Rack::ContentType
use Rack::ETag
use Rack::Runtime

# The APIs
map '/api' do
  
  # Trafikanten
  map '/trafikanten' do
    
    # Supports JSONP
    use Rack::JSONP
    
    # Version 1
    map '/v1' do
      run GuerillaAPI::Apps::Trafikanten::V1.new
    end
    
  end
  
end

# This is a temporary means to keep Heroku from killing our dyno after a
# period of inactivity. That will eradicate our Varnish cache and make the
# next request take a long time. This URL is polled from wasitup.com.
map '/pingu' do
  run lambda {[200, {}, ['pingu']]}
end
