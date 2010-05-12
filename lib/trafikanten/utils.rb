require 'open-uri'
require 'iconv'
require 'time'

module Trafikanten
  module Utils

    # Helper for retrieving URLs and converting them to UTF-8
    # Also a nice place to mock for testing
    def self.get_unfucked(url)
      Rails.logger.debug "Trafikanten API: Hitting #{url}"
      Iconv.new('UTF-8', 'LATIN1').iconv(open(url).read)
    end
    
    # Strip the crap out
    def self.clean(line)
      line.strip.gsub(/\t|\r|\n/, ' ')
    end
    
    def self.duration(from_str, to_str)
      Integer (Time.parse(to_str.gsub('.', ':')) - Time.parse(from_str.gsub('.', ':'))) / 60
    end
  end
end
