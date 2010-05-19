class RoutesController < ApplicationController
  # TODO: Cache this hit and expire it at the time of departure in the first step!
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
    
    if time_requested?
      # Cache forever
      expires_in 10.years, 'max-stale' => 10.years.to_i, :public => true
    else
      # Cache till the first departure
      max_age = (route.trip[:steps].first[:depart][:time] - Time.zone.now).to_i
      max_age = max_age > 0 ? max_age : 0
      expires_in max_age, 'max-stale' => max_age, :public => true
    end
    
    render :json => route.trip.to_json
  end
  
  private
  def get_time
    if time_requested?
      Time.zone.parse params[:date] + ' ' + params[:time]
    else
      Time.zone.now
    end
  end
  
  def time_requested?
    !params[:date].blank? && !params[:time].blank?
  end
end
