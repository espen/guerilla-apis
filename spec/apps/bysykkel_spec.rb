require File.expand_path('../../spec_helper', __FILE__)

describe GuerillaAPI::Apps::Bysykkel::V1 do
  include Rack::Test::Methods
  include RackupApp
  
  before(:all) do
    @mock_rack = Bysykkel::Rack.new({
      :name => 'Slottet',
      :online => true,
      :id => 1,
      :empty_locks => 4,
      :ready_bikes => 5,
      :lat => '123',
      :lng => '456'
    })

    @time = Time.now
    Time.stub(:now).and_return @time

  end
  
  context 'searching for racks' do
    
    context '(/racks/:id)' do
      before(:all) do
        Bysykkel::Rack.stub(:find).and_return []
      end
      
      it 'delivers json in utf-8' do
        get '/api/bysykkel/v1/racks/1'
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
      end
      
      
      it 'delivers JSONP when requested' do
        get '/api/bysykkel/v1/racks/1?callback=func'
        last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
        last_response.body.should =~ /^func\(/
      end
      
      it 'looks up racks by id and returns rack array' do
          Bysykkel::Rack.stub(:find).and_return [@mock_rack]
          get '/api/bysykkel/v1/racks/1'
          result = JSON.parse(last_response.body)
          result['racks'].class.should == Array

          # Test the first returned rack
          rack = result['racks'].first
          rack['name'].should == 'Slottet'
          rack['id'].should == 1
          rack['geo'].should == {
            'type' => 'Point',
            'coordinates' => ['456', '123']
          }
        end

        it 'returns an empty array in the JSON when no racks are found' do
          Bysykkel::Rack.stub(:find).and_return []
          get '/api/bysykkel/v1/racks/1337'
          result = JSON.parse(last_response.body)
          result['racks'].should == []
        end

        it 'caches for a minute' do
          Bysykkel::Rack.stub(:find).and_return []
          get '/api/bysykkel/v1/racks/1'
          last_response.headers['Cache-Control'].should == "public, max-age=60"
        end
   
    end    

    context '(/racks/)' do
      before(:all) do
        Bysykkel::Rack.stub(:all).and_return []
      end
      
      it 'delivers json in utf-8' do
        get '/api/bysykkel/v1/racks/'
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
      end
      
      
      it 'delivers JSONP when requested' do
        get '/api/bysykkel/v1/racks/?callback=func'
        last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
        last_response.body.should =~ /^func\(/
      end
      
      it 'looks up racks returns rack array' do
          get '/api/bysykkel/v1/racks/'
          result = JSON.parse(last_response.body)
          result['racks'].class.should == Array
          result['racks'].size.should > 1
          
          # Test the first returned rack
          rack = result['racks'].first
          rack['online'] != nil
        end

        it 'caches forever' do
          Bysykkel::Rack.stub(:all).and_return []
          get '/api/bysykkel/v1/racks/'
          last_response.headers['Cache-Control'].should == "public, max-age=30000000"
        end
   
    end

    context '(/racks/live)' do
      before(:all) do
        Bysykkel::Rack.stub(:all).and_return []
      end
      
      it 'delivers json in utf-8' do
        get '/api/bysykkel/v1/racks/live/'
        last_response.headers['Content-Type'].should == "application/json;charset=utf-8"
      end
      
      
      it 'delivers JSONP when requested' do
        get '/api/bysykkel/v1/racks/live/?callback=func'
        last_response.headers['Content-Type'].should == "application/javascript;charset=utf-8"
        last_response.body.should =~ /^func\(/
      end
      
      it 'looks up racks returns rack array with live info' do
          get '/api/bysykkel/v1/racks/live/'
          result = JSON.parse(last_response.body)
          result['racks'].class.should == Array
          result['racks'].size.should > 1
          
          # Test the first returned rack
          rack = result['racks'].first
          rack['online'].should 
        end

        it 'caches for a minute' do
          Bysykkel::Rack.stub(:all).and_return []
          get '/api/bysykkel/v1/racks/live/'
          last_response.headers['Cache-Control'].should == "public, max-age=60"
        end
   
    end


  end
end
