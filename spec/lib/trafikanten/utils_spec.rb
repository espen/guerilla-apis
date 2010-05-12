require 'spec_helper'

describe Trafikanten::Utils do
  it 'filters crap' do
    Trafikanten::Utils.clean("\t\t\t\t\t   Oslo  \t\t\t\n").should == "Oslo"
  end
  
  it 'calculates duration in minutes' do
    Trafikanten::Utils.duration("12.30", "12.50").should == 20
  end
end
