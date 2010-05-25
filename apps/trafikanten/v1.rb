class GuerillaAPI::Apps::Trafikanten::V1 < Sinatra::Base
  # Everything is JSON in UTF8
  before do
    content_type 'application/json', :charset => 'utf-8'
  end
  
  # Specific departure
  #
  # TODO: Cache also in Memcache if more params than required is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/route/:from_id/:to_id/:date/:time' do
    cache_forever
    {:this => 'That'}.to_json
  end

  # Next departure
  #
  # TODO: Cache also in Memcache if more params than required is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/route/:from_id/:to_id' do
    #route = TrafikantenTravel::Route.new(params[:from_id], params[:to_id], Time.now)
    {:this => 'That'}.to_json
  end

  # Search for stations
  #
  # TODO: Cache also in Memcache if more params than :name is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/stations/:name' do
    cache_forever

    stations = TrafikantenTravel::Station.find_by_name params[:name]
    {:stations => stations.map do |station| 
      has_geo = station.lat && station.lng
      { :name => station.name,
        :id => station.id,
        :geo => has_geo ? {'Type'=>'Point','coordinates'=>[station.lng,station.lat]} : nil
      }
      end
    }.to_json
  end

  private
  
  def cache_forever
    expires 30000000, :public
  end
end
