# This file is used by Rack-based servers to start the application.
require 'rack/throttle'
use Rack::Throttle::Interval, :min => 3.0

require ::File.expand_path('../config/environment',  __FILE__)
run Trafikanten::Application
