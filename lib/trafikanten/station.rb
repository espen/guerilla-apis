module Trafikanten
  class Station
    # The URL we use for searching for stations
    BASE = "http://m.trafikanten.no/BetLink.asp?fra=%s&DStoppAddress=1"

    # Regex to parse the station id and name
    #<a href="ToCombo.asp?fra=01351445%3AAker&amp;deptype=1" title="Velg">Aker (Råde)</a><br/>
    STATION_REGEX = /<a.*fra=(\d+).*deptype.*"Velg">(.+)<\/a><br\/>/

    # Deliver a 2D-array of stations on the form [id, name]
    def self.find_by_name(name)
      url = BASE % CGI.escape(name)
      doc = Trafikanten::Utils.fetch(url)
      doc.scan(STATION_REGEX)
    end

  end
end
