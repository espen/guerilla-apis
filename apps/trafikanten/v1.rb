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
    time = Time.parse "#{params[:date]} #{params[:time]}"
    find_route_by_date(params[:from_id], params[:to_id], time)    
  end

  # Next departure
  #
  # TODO: Cache also in Memcache if more params than required is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/route/:from_id/:to_id' do
    # Error happened
    find_route_by_date(params[:from_id], params[:to_id], Time.now)    
  end

  # Search for stations
  #
  # TODO: Cache also in Memcache if more params than :name is sent
  #       Varnish works on exact URL, so someone could hit our backend
  #       repeatedly by appending bogus GET params, or different JSONP callbacks.
  get '/stations/:name' do
    cache_forever
    find_stations params[:name]
  end

  private
  
  def route_to_json(route)
    {
      'source' => 'trafikanten.no',
      'route' => {
        'duration' => route.duration,
        'steps' => route.steps.map do |step|
          {
            'type' => step.type,
            'line' => step.line,
            'duration' => step.duration,
            'depart' => step.depart,
            'arrive' => step.arrive
          }
        end
      }
    }.to_json
  end
  
  def cache_forever
    expires 30000000, :public
  end
  
  def find_route(from, to, time = Time.now)
    from  = TrafikantenTravel::Station.new({:id => from})
    to    = TrafikantenTravel::Station.new({:id => to})
    TrafikantenTravel::Route.find(from, to, time)
  end
  
  def find_route_by_date(from, to, time)
    begin
      route = find_route(params[:from_id], params[:to_id], time)
    rescue TrafikantenTravel::Error => e
      status 400
      content_type 'text/plain', :charset => 'utf-8'
      return e.message
    end
    
    if route.steps == []
      # Pretty sure this lasts forever
      cache_forever
      status 404
      return nil
    end
    
    unless response.headers['Cache-Control']
      time_until_departure = route.steps[0].depart[:time]
      # Cache intil the next departure. Include the minute for the departure
      expires ((time_until_departure - Time.now).to_i + 60), :public
    end
    
    route_to_json(route)
  end
  
  def find_stations(name)
    stations = TrafikantenTravel::Station.find_by_name(name)
    {
      :source => 'trafikanten.no',
      :stations => stations.map do |station| 
      has_geo = station.lat && station.lng
      { :name => station.name,
        :id => station.id,
        :geo => has_geo ? {'Type'=>'Point','coordinates'=>[station.lng,station.lat]} : nil
      }
      end
    }.to_json
  end
  
end
