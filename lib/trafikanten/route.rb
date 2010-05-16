require 'pp'

module Trafikanten
  class Error < StandardError;end
  class BadRequest < Error;end
  class APIError < Error;end
  
  class Route
    attr_accessor :trip
    
    def initialize(from, to, time = Time.now)
      date  = time.strftime "%d.%m.%Y"
      clock = time.strftime "%H.%M"
      url = "http://m.trafikanten.no/BetRes.asp?fra=#{from}%3A&DepType=1&date=#{date}&til=#{to}%3A&ArrType=1&transport=2,%207,%205,%208,%201,%206,%204&MaxRadius=700&type=1&tid=#{clock}"
      @trip = parse(Trafikanten::Utils.fetch(url))
    end
    
    private
    
    # Regexes for matching steps in the HTML
    WALK    = /^G.+fra (.+) til (.+) ca. (\d) minutt/
    WAIT    = /^Vent  (\d+) minutt/
    TRAIN   = /^Tog (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/
    BUS     = /^Buss (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/
    BOAT    = /^B.t (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/
    SUBWAY  = /^T-bane (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/
    TRAM    = /^Sporvogn (.+).+Avg: (.+) (\d{2}.\d{2}).+Ank:(.+) (\d{2}.\d{2})/
    
    # Wrap the actual parsing and check for errors if something goes wrong
    # Saves us the trouble of checking all potential errors on every request
    def parse(doc)
      begin
        do_parse(doc)
      rescue => e
        if doc =~ /Ingen forbindelse funnet eller ingen stoppesteder funnet/
          return {}
        end

        if doc =~ /Microsoft VBScript runtime/
          raise BadRequest
        end

        if doc =~ /Trafikanten - Feilmelding/
          doc =~ /<p>(.+)<\/p>/
          raise Error.new($1)
        end

        # Oops.
        raise e
      end
    end
    
    def do_parse(doc)
      trip = {}
      doc = Nokogiri::HTML.parse(doc)
      
      trip[:steps] = doc.css('p')[1..-1].inject([]) do |ary, step|
        # Clean the text, mostly for better debug output
        step = Trafikanten::Utils.clean(step.text)
        
        # Fix for broken formatting
        # All steps but this one is in its own paragraph-tag
        # Need to split them and parse both
        if step =~ /^(Vent .+ minutter|minutt)(.+)/
          ary << parse_step($1)
          ary << parse_step($2)
        else
          ary << parse_step(step)
        end
      end
      
      # Duration is the sum of all steps
      trip[:duration] = trip[:steps].inject(0) do |i, step|
        i += step[:duration] if step[:duration]
      end
      
      # Arrive is the station arriving at in the last step
      trip[:arrive] = trip[:steps].last[:arrive]
      
      # Depart is the first station we depart from
      trip[:steps].each do |step|
        if step[:depart]
          trip[:depart] = step[:depart] and break
        end
      end
      trip
    end
    
    def parse_step(step)
      parsed = {}
      case step
      when WAIT
        parsed[:type]     = :wait
        parsed[:duration] = $1.to_i
        return parsed
      when WALK
        parsed[:type]     = :walk
        parsed[:duration] = $3.to_i
        parsed[:depart]   = $1
        parsed[:arrive]   = $2
        return parsed
      when TRAIN
        parsed[:type]     = :train
      when BUS
        parsed[:type]     = :bus
      when BOAT
        parsed[:type]     = :boat
      when SUBWAY
        parsed[:type]     = :subway
      when TRAM
        parsed[:type]     = :tram
      end
      # Common parsing for TRAIN / BUS / BOAT / SUBWAY / TRAM
      parsed[:line]     = $1.strip
      parsed[:duration] = Trafikanten::Utils.duration($3, $5)
      parsed[:depart]   = $2
      parsed[:arrive]   = $4
      parsed
    end
    
  end
end
