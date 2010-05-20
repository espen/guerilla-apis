class StationsController < ApplicationController
  before_filter do
    cache 1.day
  end
  
  def find
    station = Trafikanten::Station.find_by_name(params[:name])
    return not_found if station.nil?
    
    result = result_hash_for('trafikanten.no')
    result[:station] = station
    render :json => result.to_json
  end
  
  def find_all
    all = Trafikanten::Station.find_all_by_name(params[:name])
    return not_found if all.empty?
    
    result = result_hash_for('trafikanten.no')
    result[:stations] = all
    render :json => result.to_json    
  end
  
  private
  
  def not_found
    render :text => "No stations found", :status => :not_found and return
  end

end
