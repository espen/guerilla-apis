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
          get '/api/trafikanten/v1/route/1234/1234'
          last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
        end

        it 'returns 400 when an error occurred at trafikanten.no'

        it 'returns 404 when route was not found' do
          TrafikantenTravel::Route.stub(:parse).and_return {}

          get '/api/trafikanten/v1/route/1234/1234'
          last_response.status.should == 404
          last_response.body.should == 'Ingen forbindelse funnet eller ingen stoppesteder funnet'
        end

        it 'caches until the next departure'
        #last_response.headers['Cache-Control'].should == "public, max-age="
      end
    end
    context 'at a specific time and date' do

      context '(/route/:from/:to/:date/:time)' do
        it 'caches forever' do
          get '/api/trafikanten/v1/route/1234/1234/2010-04-29/12:00'
          last_response.headers['Cache-Control'].should == "public, max-age=30000000"
        end

        it 'returns 404 when no route was found'

      end      
    end
  end
  
end
