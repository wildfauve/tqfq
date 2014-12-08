class CountDim
  
  attr_accessor :dim_name
  
  include Enumerable
  
  def initialize(dim: nil)
    @dim_name = dim
    @collection = {} 
  end
  
  def add(system: nil)
    coll = system.send(@dim_name).try(:value)
    if @collection[coll]
      @collection[coll] += 1
    else
      @collection[coll] = 1
    end
  end
  
  
  def each(&block)
    @collection.each(&block)
  end
  
end