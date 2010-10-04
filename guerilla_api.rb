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
module GuerillaAPI
  module Apps
    autoload :Bysykkel, 'apps/bysykkel'
    autoload :Trafikanten, 'apps/trafikanten'
  end
end