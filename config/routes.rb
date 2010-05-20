Trafikanten::Application.routes.draw do |map|

  # Ze APIs
  namespace :api do
    
    # Trafikanten
    namespace :trafikanten do
    
      # API version 1
      namespace :v1 do
        
        # Stations
        namespace :stations do
          # Up to 20 results
          match '/:name', :to => 'stations#find_all'
          # 1 result
          match '/one/:name', :to => 'stations#find'
        end

        # Routes
        namespace :routes do
          match '/:from_id/:to_id(/:date/:time)', :to => 'routes#find',
            :from_id => /\d+/,
            :to_id => /\d+/,
            :date => /\d{4}-\d{2}-\d{2}/,
            :time => /\d{2}:\d{2}/
        end

      end
      
    end
    
  end
end
