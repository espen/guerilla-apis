Trafikanten::Application.routes.draw do |map|

  # Ze APIs
  namespace :api do
    
    # API version 1
    namespace :v1 do
    
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
