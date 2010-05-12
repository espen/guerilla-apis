require 'spec_helper'

describe Trafikanten::Route do
  it 'parses Trafikanten HTML into data structures' do
    doc = File.read('/Users/botti/Desktop/route.txt')
    parsed = Trafikanten::Route.parse(doc)
    parsed.class.should == Hash
    
    # Test main trip data
    parsed[:duration].should == 136
    parsed[:arrive].should == "Gressholmen"
    parsed[:depart].should == "Holmestrand [tog]"

    parsed[:steps].class.should == Array
    
    # Test first step
    step = parsed[:steps].first
    step[:duration].should == 64
    step[:depart].should == "Holmestrand [tog]"
    step[:arrive].should == "Oslo Sentralstasjon [tog]"
    
    # Test last step
    step = parsed[:steps].last
    step[:duration].should == 15
    step[:depart].should =~ /Vippetangen \[b.t\]/ # Damn nordic characters and Ruby!
    step[:arrive].should == "Gressholmen"
    
  end
end
