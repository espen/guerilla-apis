class StationsController < ApplicationController
  before_filter do
    cache 1.week
  end
  
  def find
    station = Trafikanten::Station.find_by_name(params[:name])
    
    result = result_hash_for('trafikanten.no')
    result[:station] = station
    render :json => result.to_json
  end
end
