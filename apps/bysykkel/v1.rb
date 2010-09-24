class GuerillaAPI::Apps::Bysykkel::V1 < Sinatra::Base
  # Everything is JSON in UTF8
  before do
    content_type 'application/json', :charset => 'utf-8'
  end

  # Search for stations
  #
  # TODO: Cache also in Memcache if more params than :name is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/station/:id' do
    cache_forever
    find_station params[:id]
  end

  get '/station/' do
    cache_forever
    all_stations
  end

  private
  
  def cache_forever
    expires 30000000, :public
  end
  
  def all_stations()
    stations = Bysykkel::Station.all()
    {
      :source => 'smartbikeportal.clearchannel.no',
      :stations => stations.map do |station| 
        has_geo = station.lat && station.lng
      {
        'id' => station.id,
        'ready_bikes' => station.ready_bikes,
        'empty_locks' => station.empty_locks,
        'online' => station.online,
        'description' => station.description,
        'geo' => has_geo ? {'Type'=>'Point','coordinates'=>[station.lng,station.lat]} : nil
      }
      end
    }.to_json
  end

  def find_station(id)
    has_geo = station.lat && station.lng
    station = Bysykkel::Station.find(id)
    {
      :source => 'smartbikeportal.clearchannel.no',
      :stations => {
        'id' => station.id,
        'ready_bikes' => station.ready_bikes,
        'empty_locks' => station.empty_locks,
        'online' => station.online,
        'description' => station.description,
        'geo' => has_geo ? {'Type'=>'Point','coordinates'=>[station.lng,station.lat]} : nil
      }
    }.to_json
  end
  
end
