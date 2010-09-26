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
      
      it 'looks up racks by id and returns array of racks' do
          Bysykkel::Rack.stub(:find).and_return [@mock_rack]
          get '/api/bysykkel/v1/racks/1'
          result = JSON.parse(last_response.body)
          result['racks'].class.should == Array

          # Test the first returned rack
          rack = result['racks'].first
          rack['name'].should == 'Slottet'
          rack['id'].should == 1
          rack['geo'].should == {
            'Type' => 'Point',
            'coordinates' => ['456', '123']
          }
        end

        it 'returns an empty array in the JSON when no racks are found' do
          Bysykkel::Rack.stub(:find).and_return []
          get '/api/bysykkel/v1/racks/1337'
          result = JSON.parse(last_response.body)
          result['racks'].should == []
        end

        it 'caches forever' do
          Bysykkel::Rack.stub(:find).and_return []
          get '/api/bysykkel/v1/racks/'
          last_response.headers['Cache-Control'].should == "public, max-age=30000000"
        end     
      

   
    end    
  end
end
