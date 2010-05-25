require File.expand_path('../../spec_helper', __FILE__)

describe GuerillaAPI::Apps::Trafikanten::V1 do
  include Rack::Test::Methods
  include RackupApp
  
  before(:all) do
    @mock_station = TrafikantenTravel::Station.new({
      :name => 'Tullestasjon',
      :id => '29',
      :lat => '123',
      :lng => '456',
      :type => 1
    })
    
    @mock_route = TrafikantenTravel::Route.new(@mock_station, @mock_station)
  end
  
  context 'searching for stations' do
    
    context '(/station/:name)' do
      before(:all) do
        TrafikantenTravel::Station.stub(:find_by_name).and_return []
      end
      
      it 'delivers json in utf-8' do
        get '/api/trafikanten/v1/stations/Stensberg'
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
      end
      
      it 'delivers JSONP when requested' do
        get '/api/trafikanten/v1/stations/Stensberg?callback=func'
        last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
        last_response.body.should =~ /^func\(/
      end

      it 'looks up stations by name and returns array of stations' do
        TrafikantenTravel::Station.stub(:find_by_name).and_return [@mock_station]
        get '/api/trafikanten/v1/stations/Tullestasjon'
        result = JSON.parse(last_response.body)
        result['stations'].class.should == Array
        
        # Test the first returned station
        station = result['stations'].first
        station['name'].should == 'Tullestasjon'
        station['id'].should == '29'
      end
      
      it 'returns an empty array in the JSON when no stations are found' do
        TrafikantenTravel::Station.stub(:find_by_name).and_return []
        get '/api/trafikanten/v1/stations/Finnesikke'
        result = JSON.parse(last_response.body)
        result['stations'].should == []
      end
      
      it 'includes geoJSON for stations that have lat lng' do
        TrafikantenTravel::Station.stub(:find_by_name).and_return [@mock_station]
        get '/api/trafikanten/v1/stations/Tullestasjon'
        result = JSON.parse(last_response.body)
        result['stations'].first['geo'].should == {
          'Type' => 'Point',
          'coordinates' => ['456', '123']
        }
      end
      
      it 'sets geoJSON to nil for stations that dont have lat lng' do
        @mock = @mock_station.dup
        @mock.lat = nil
        @mock.lng = nil
        
        TrafikantenTravel::Station.stub(:find_by_name).and_return [@mock]
        get '/api/trafikanten/v1/stations/Tullestasjon'
        result = JSON.parse(last_response.body)
        result['stations'].first['geo'].should == nil
      end
      
      it 'caches forever' do
        TrafikantenTravel::Station.stub(:find_by_name).and_return []
        get '/api/trafikanten/v1/stations/Finnesikke'
        last_response.headers['Cache-Control'].should == "public, max-age=30000000"
      end
    end    
  end

  context 'searching for a route between stations' do
    context 'next departure' do
      context '(/route/:from/:to)' do
        
        it 'delivers json in utf-8' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234'
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        end
        
        it 'delivers JSONP when requested' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234?callback=func'
          last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
          last_response.body.should =~ /^func\(/
        end

        it 'returns 400 when an normal error occurred at trafikanten.no' do
          TrafikantenTravel::Route.stub(:find).and_raise TrafikantenTravel::Error.new('Bad things happened')
          get '/api/trafikanten/v1/route/1234/1234'
          last_response.status.should == 400
          last_response.body.should == 'Bad things happened'          
        end
        
        it 'returns 400 when an abnormal error occurred at trafikanten.no' do
          TrafikantenTravel::Route.stub(:find).and_raise TrafikantenTravel::BadRequest.new('Very bad things happened')
          get '/api/trafikanten/v1/route/1234/1234'
          last_response.status.should == 400
          last_response.body.should == 'Very bad things happened'
        end
        
        context 'no route found' do
          before(:each) do
            TrafikantenTravel::Route.stub(:find).and_return @mock_route
            get '/api/trafikanten/v1/route/1234/1234'            
          end
          
          it 'returns 404' do
            last_response.status.should == 404
          end

          it 'caches forever' do
            last_response.headers['Cache-Control'].should == "public, max-age=30000000"
          end
          
          it 'returns no body' do
            last_response.body.should == ''
          end
          
        end

        it 'caches until the next departure' do
          mocked = @mock_route.dup
          time_now = Time.now
          Time.stub(:now).and_return time_now
          
          first_step = TrafikantenTravel::Route::Step.new
          first_step.depart = {
            :station => 'Tullestasjonen',
            :time => time_now + 120 # In 2 minutes
          }
          mocked.steps << first_step
          TrafikantenTravel::Route.stub(:find).and_return mocked
          
          get '/api/trafikanten/v1/route/1234/1234'
          last_response.headers['Cache-Control'].should == "public, max-age=180"
        end
        
        it 'returns the correct structure' do
          time_now = Time.now
          Time.stub(:now).and_return time_now
          
          fully_mocked = TrafikantenTravel::Route.new(TrafikantenTravel::Station.new, TrafikantenTravel::Station.new, time_now)
          
          duration = 0
          4.times do |s|
            step = TrafikantenTravel::Route::Step.new
            step.duration = rand(20) +1 
            
            step.depart = {
              :station => "Startstasjon #{s}",
              :time => time_now + duration * 60
            }
            
            step.arrive = {
              :station => "Stopstasjon #{s}",
              :time => time_now + step.duration * 60
            }
            
            step.type = :train
            
            duration = duration + step.duration
            fully_mocked.steps << step
          end
          
          fully_mocked.duration = duration

          TrafikantenTravel::Route.stub(:find).and_return fully_mocked
          get '/api/trafikanten/v1/route/12345/12345'
          result = JSON.parse(last_response.body)
          
          # Full duration
          route = result['route']
          route['duration'].should == duration
          
          # First step
          step = route['steps'][0]
          step['depart']['station'].should == 'Startstasjon 0'
          step['arrive']['station'].should == 'Stopstasjon 0'
          step['type'].should == 'train'

          # Last step
          step = route['steps'][3]
          step['depart']['station'].should == 'Startstasjon 3'
          step['arrive']['station'].should == 'Stopstasjon 3'
          step['type'].should == 'train'
        end
        
      end
    end
    
    context 'at a specific time and date' do

      context '(/route/:from/:to/:date/:time)' do

        it 'delivers json in utf-8' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        end

        it 'delivers JSONP when requested' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00?callback=func'
          last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
          last_response.body.should =~ /^func\(/
        end
        
        it 'caches forever' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.headers['Cache-Control'].should == "public, max-age=30000000"
        end

        it 'returns 404 when no route was found' do
          TrafikantenTravel::Route.stub(:find).and_return @mock_route
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.status.should == 404
          last_response.body.should == ''
        end
        
        it 'returns 400 when an normal error occurred at trafikanten.no' do
          TrafikantenTravel::Route.stub(:find).and_raise TrafikantenTravel::Error.new('Bad things happened')
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.status.should == 400
          last_response.body.should == 'Bad things happened'          
        end
        
        it 'returns 400 when an abnormal error occurred at trafikanten.no' do
          TrafikantenTravel::Route.stub(:find).and_raise TrafikantenTravel::BadRequest.new('Very bad things happened')
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.status.should == 400
          last_response.body.should == 'Very bad things happened'
        end
        
        it 'returns the correct structure' do
          time_now = Time.now
          Time.stub(:now).and_return time_now
          
          fully_mocked = TrafikantenTravel::Route.new(TrafikantenTravel::Station.new, TrafikantenTravel::Station.new, time_now)
          
          duration = 0
          4.times do |s|
            step = TrafikantenTravel::Route::Step.new
            step.duration = rand(20) +1 
            
            step.depart = {
              :station => "Startstasjon #{s}",
              :time => time_now + duration * 60
            }
            
            step.arrive = {
              :station => "Stopstasjon #{s}",
              :time => time_now + step.duration * 60
            }
            
            step.type = :train
            
            duration = duration + step.duration
            fully_mocked.steps << step
          end
          
          fully_mocked.duration = duration

          TrafikantenTravel::Route.stub(:find).and_return fully_mocked
          get '/api/trafikanten/v1/route/12345/12345/2010-04-29/12:00'
          result = JSON.parse(last_response.body)
          
          # Full duration
          route = result['route']
          route['duration'].should == duration
          
          # First step
          step = route['steps'][0]
          step['depart']['station'].should == 'Startstasjon 0'
          step['arrive']['station'].should == 'Stopstasjon 0'
          step['type'].should == 'train'

          # Last step
          step = route['steps'][3]
          step['depart']['station'].should == 'Startstasjon 3'
          step['arrive']['station'].should == 'Stopstasjon 3'
          step['type'].should == 'train'
        end
        
      end
    end
  end
  
end
