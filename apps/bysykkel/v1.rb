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
  get '/stations/:id' do
    cache_forever
    find_station params[:id]
  end

  get '/stations/' do
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
      :stations => stations
    }.to_json
  end

  def find_station(id)
    station = Bysykkel::Station.find_by_id(id)
    {
      :source => 'smartbikeportal.clearchannel.no',
      :stations => station
      }
    }.to_json
  end
  
end
