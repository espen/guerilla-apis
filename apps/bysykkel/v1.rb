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
  get '/racks/:id' do
    cache_forever
    find_rack params[:id]
  end

  get '/racks/' do
    cache_forever
    find_racks
  end

  private
  
  def cache_forever
    expires 30000000, :public
  end
  
  def find_racks()
    racks = BysykkelTravel::Rack.all()
    {
      :source => 'trafikanten.no',
      :racks => racks.map do |rack| 
      {
        'ready_bikes' => rack.ready_bikes,
        'empty_locks' => rack.empty_locks,
        'online' => rack.online,
        'description' => rack.description,
        'latitude' => rack.latitude,
        'longitude' => rack.longitude
      }
      end
    }.to_json
  end

  def find_rack(id)
    racks = BysykkelTravel::Rack.find_by_id(id)
    {
      :source => 'trafikanten.no',
      :racks => racks.map do |rack| 
      {
        'ready_bikes' => rack.ready_bikes,
        'empty_locks' => rack.empty_locks,
        'online' => rack.online,
        'description' => rack.description,
        'latitude' => rack.latitude,
        'longitude' => rack.longitude
      }
      end
    }.to_json
  end
  
end
