Trafikanten::Application.routes.draw do |map|

  namespace :api do
    
    # API version 1
    namespace :v1 do
      
      # Stations
      namespace :stations do
        match '/:name', :to => 'stations#show'
        match '/search/:name', :to => 'stations#search'
      end
      
      # Routes
      namespace :routes do
        match '/:from_id/:to_id(/:date/:time)', :to => 'routes#find'
      end
    end
    
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
