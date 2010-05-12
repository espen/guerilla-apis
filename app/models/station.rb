class Station
  attr_accessor :name, :id
  
  def initialize(attrs = {})
    attrs.each do |k,v|
      self.__send__("#{k}=", v)
    end
  end
  
  # Give an array of Station-objects
  def self.find_by_name(name)
    Trafikanten::Station.find_by_name(name).map do |station|
      self.new({:id => station.shift, :name => station.shift})
    end
  end
  
end
