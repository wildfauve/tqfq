class Quadrant
  
  attr_accessor :position, :ct, :count_dims, :quad_position
  
  #@@quads = [:replace, :refactor, :keep, :enhance, :not_assessed]
  @@quads = {replace: {pos: :bottom_left}, 
            refactor: {pos: :top_left}, 
            keep: {pos: :top_right}, 
            enhance: {pos: :bottom_right}, 
            not_assessed: {}}
  @@valid_quads = [:replace, :refactor, :keep, :enhance]
  @@count_dims = [:pace_layer]
  
  def self.generate(total_sys: nil, assess_total: nil)
    q = []
    @@quads.each {|qu, v| q << self.new(position: qu, quad_position: v[:pos], total_sys: total_sys, assess_total: assess_total) }
    q
  end
  
  def self.valid?(quad)
    return false if quad.nil?
    @@valid_quads.include?(quad.try(:value).to_sym) ? true : false
  end
  
  def self.get_name(quad)
    return :not_assessed if quad.nil?
    q = quad.value.to_sym
    @@quads.has_key?(quad.value.to_sym) ? quad.value.to_sym : :not_assessed
  end
  
  def self.quad_dims
    @@count_dims
  end
  
  def initialize(position: nil, quad_position: nil, total_sys: nil, assess_total: nil)
    raise if !position
    @position = position
    @total_sys = total_sys
    @assess_sys = assess_total
    @ct = 0
    @tot_percent = 0.0
    @assess_percent = 0.0
    @count_dims = []
    @quad_position = quad_position
    @@count_dims.each {|d| @count_dims << CountDim.new(dim: d)}
    self
  end
  
  def add(system: nil)
          #counts[tqfq][system.pace_layer] ? counts[tqfq][system.pace_layer] += 1 : counts[tqfq][system.pace_layer] = 1
    @ct += 1
    @tot_percent = @ct / @total_sys.to_f
    @assess_percent = @ct / @assess_sys.to_f
    @count_dims.each {|dim| dim.add(system: system) }
  end

  def tot_percent
    @tot_percent * 100
  end

  def assess_percent
    @assess_percent * 100
  end
  
  
end