class StationsController < ApplicationController
  def search
    all = Station.find_by_name(params[:name])
    render :json => all.map(&:name).to_json
  end
  
  def show
    
  end
end
