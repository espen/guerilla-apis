class GuerillaAPI::Apps::Bysykkel::V1 < Sinatra::Base
  # Everything is JSON in UTF8
  before do
    content_type 'application/json', :charset => 'utf-8'
  end

  use HoptoadNotifier::Rack
  enable :raise_errors
  
  # Search for racks
  #
  # TODO: Cache also in Memcache if more params than :id is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/racks/' do
    cache_forever
  begin
    racks = CACHE.get('racks')
  rescue
    racks = payload(Bysykkel::Rack.all(), false)
    CACHE.set('racks', racks)
  end
    racks
  end

  get '/racks/live/' do
    cache_min
    payload(Bysykkel::Rack.all())
  end

  get '/racks/:id' do
    cache_min
    payload(Bysykkel::Rack.find(params[:id]))
  end

  private
  
  def cache_forever
    expires 30000000, :public
  end

  def cache_min
    expires 60, :public
  end
  
  def payload(racks, showAvailability = true)
      {
        :source => 'smartbikeportal.clearchannel.no',
        :racks => racks.map do |rack| 
        has_geo = rack.lat && rack.lng
        rack_json = {
          'id' => rack.id,
          'name' => rack.name,
          'geo' => has_geo ? {'type'=>'Point','coordinates'=>[rack.lng,rack.lat]} : nil
        }
        if showAvailability
          rack_json[:ready_bikes] = rack.ready_bikes
          rack_json[:empty_locks] = rack.empty_locks
          rack_json[:online] = rack.online
        end
        rack_json
        end
      }.to_json
  end
  
end
