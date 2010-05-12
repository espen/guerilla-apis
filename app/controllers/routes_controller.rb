class RoutesController < ApplicationController
  def find
    begin
      route = Trafikanten::Route.new(params[:from_id], params[:to_id], get_time)
    rescue => e
      raise e
      head :bad_request and return
    end
    
    if route.trip.empty?
      head :not_found and return
    end
    
    render :json => route.trip.to_json
  end
  
  private
  def get_time
    if params[:date] && params[:time]
      Time.parse params[:date] + ' ' + params[:time]
    else
      Time.now
    end
  end
end
