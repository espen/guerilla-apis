require File.expand_path('../spec_helper', __FILE__)

describe GuerillaAPI do
  include Rack::Test::Methods
  include RackupApp
  
  context '/pingu' do
    it 'responds with "200 pingu" not cached' do
      get '/pingu'
      last_response.body.should == 'pingu'
      last_response.status.should == 200
      last_response.headers['Cache-Control'].should be_nil
    end    
  end
end
