class GuerillaAPI::Apps::Bysykkel::V1 < Sinatra::Base
  # Everything is JSON in UTF8
  before do
    content_type 'application/json', :charset => 'utf-8'
  end

  # Search for racks
  #
  # TODO: Cache also in Memcache if more params than :id is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/racks/' do
    cache_forever
    all_racks
  end

  get '/racks/:id' do
    cache_forever
    find_rack params[:id]
  end


  private
  
  def cache_forever
    expires 30000000, :public
  end
  
  def all_racks()
    racks = Bysykkel::Rack.all()
    {
      :source => 'smartbikeportal.clearchannel.no',
      :racks => racks.map do |rack| 
        has_geo = rack.lat && rack.lng
      {
        'id' => rack.id,
        'ready_bikes' => rack.ready_bikes,
        'empty_locks' => rack.empty_locks,
        'online' => rack.online,
        'name' => rack.name,
        'geo' => has_geo ? {'type'=>'Point','coordinates'=>[rack.lng,rack.lat]} : nil
      }
      end
    }.to_json
  end

  def find_rack(id)
    rack = Bysykkel::Rack.find(id)
    has_geo = rack.lat && rack.lng
    {
      :source => 'smartbikeportal.clearchannel.no',
      :racks => {
        'id' => rack.id,
        'ready_bikes' => rack.ready_bikes,
        'empty_locks' => rack.empty_locks,
        'online' => rack.online,
        'name' => rack.name,
        'geo' => has_geo ? {'type'=>'Point','coordinates'=>[rack.lng,rack.lat]} : nil
      }
    }.to_json
  end
  
end
