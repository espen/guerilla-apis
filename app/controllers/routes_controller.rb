class RoutesController < ApplicationController
  def find
    begin
      route = Trafikanten::Route.new(params[:from_id], params[:to_id], get_time)
      route.parse
    rescue => e
      if e.kind_of? Trafikanten::Error
        render :text => e.message, :status => :bad_request and return
      else
        raise e
      end
    end
    
    if route.trip.empty?
      render :text => "No available routes found", :status => :not_found and return
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
