# Load path
$: << File.expand_path('../', __FILE__)

require "rubygems"
require "bundler"
Bundler.setup

# Require all the needed gems
Bundler.require(:default)

configure do
  CACHE = Memcached.new
end


HoptoadNotifier.configure do |config|
  config.api_key = 'b1cb78117fb71a6b4bd7cad05422b15b'
  config.development_lookup = true
end

module GuerillaAPI
  module Apps
    autoload :Bysykkel, 'apps/bysykkel'
    autoload :Trafikanten, 'apps/trafikanten'
  end
end