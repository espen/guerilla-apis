class GuerillaAPI::Apps::Trafikanten::V1 < Sinatra::Base
  # Everything is JSON in UTF8
  before do
    content_type 'application/json', :charset => 'utf-8'
  end
  
  # Specific departure
  get '/route/:from_id/:to_id/:date/:time' do
    cache_forever
    {:this => 'That'}.to_json
  end

  # Next departure
  get '/route/:from_id/:to_id' do
    #route = TrafikantenTravel::Route.new(params[:from_id], params[:to_id], Time.now)
    {:this => 'That'}.to_json
  end

  # Search for stations
  get '/stations/:name' do
    cache_forever
    stations = TrafikantenTravel::Station.find_by_name params[:name]
    {:stations => stations.map{|s| station_to_json(s) }}.to_json
  end

  private
  
  def cache_forever
    expires 30000000, :public
  end
  
  def station_to_json(station)
    has_coordinates = station.lat && station.lng
    { :name => station.name,
      :id => station.id,
      :geo => has_coordinates ? {'Type'=>'Point','coordinates'=>[station.lng,station.lat]} : nil
    }
  end
end
