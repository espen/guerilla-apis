require 'sinatra'
require 'json'

require File.expand_path('../vendor/trafikanten-travel/lib/trafikanten_travel', __FILE__)

module GuerillaAPI
  module Apps
    autoload :Trafikanten, 'apps/trafikanten'
  end
end
