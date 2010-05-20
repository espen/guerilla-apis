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

    cache :forever if time_requested?
    
    if route.trip.empty?
      render :text => "No available routes found", :status => :not_found and return
    end
    
    # Cache till the first departure if not bad request or 404 and time isnt requested
    unless time_requested?
      cache(cache_time_for(route.trip))
    end
    
    result = {}
    result[:source] = 'trafikanten.no'
    result[:route] = route.trip
    render :json => result.to_json
  end
  
  private
  def get_time
    time_requested? ? (Time.zone.parse params[:date] + ' ' + params[:time]) : Time.zone.now
  end
  
  def time_requested?
    !params[:date].blank? && !params[:time].blank?
  end
  
  def cache(age)
    time = (age == :forever) ? 10.years : age
    expires_in time.to_i, 'max-stale' => time.to_i, :public => true
  end
  
  def cache_time_for(trip)
    departs = nil
    trip[:steps].each do |step|
      if step[:depart].has_key? :time
        departs = step[:depart][:time] and break
      end
    end
    
    if departs
      return (departs - Time.zone.now).to_i + 60
    end
  end
end
