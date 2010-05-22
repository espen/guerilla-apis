class StationsController < ApplicationController
  before_filter do
    cache 1.week
  end
  
  def find
    stations = Trafikanten::Station.find_by_name(params[:name])
    
    result = result_hash_for('trafikanten.no')
    
    result[:stations] = stations.inject([]) do |arr, station|
      arr << {
        :name => station.name, 
        :id => station.id,
        :geo => {
          'type' => 'Point',
          'coordinates' => [station.lng, station.lat]
        }
      }
    end
    
    render :json => result.to_json
  end
end
