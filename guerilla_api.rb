# Load path
$: << File.expand_path('../', __FILE__)

require "rubygems"
require "bundler"
Bundler.setup

# Our dependencies
require 'rack'
require 'json'
require 'rack/contrib/jsonp'
require 'sinatra'
require 'trafikanten_travel'

# Monkey-patch Rack::JSONP
require 'lib/rack/jsonp'

module GuerillaAPI
  module Apps
    autoload :Trafikanten, 'apps/trafikanten'
  end
end
