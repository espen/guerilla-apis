# Load path
$: << File.expand_path('../', __FILE__)

require "rubygems"
require "bundler"
Bundler.setup

# Require all the needed gems
Bundler.require(:default)

# Monkey-patch Rack::JSONP
require 'lib/rack/jsonp'

module GuerillaAPI
  module Apps
    autoload :Trafikanten, 'apps/trafikanten'
  end
end
