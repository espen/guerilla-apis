class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def result_hash_for(api)
    {:source => api}
  end
  
  def cache(age)
    time = (age == :forever) ? 10.years : age
    expires_in time.to_i, 'max-stale' => time.to_i, :public => true
  end
  
end
