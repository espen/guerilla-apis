require File.expand_path('../../guerilla_api', __FILE__)

require "rubygems"
require "bundler"
Bundler.setup
Bundler.require(:test)

module RackupApp  
  # Return the app forged by config.ru
  def app
    Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__))[0]
  end
end
