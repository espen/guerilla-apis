require "rubygems"
require "bundler"
Bundler.setup

# Our dependencies
require 'rack'
require 'json'
require 'sinatra'
require 'trafikanten_travel'

module GuerillaAPI
  module Apps
    autoload :Trafikanten, 'apps/trafikanten'
  end
end
