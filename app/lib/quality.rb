class Quality
  
  attr_accessor :quads
  
  
  def initialize(systems: nil)
    @systems = systems
    @dims = []
    @pace = systems.map(&:pace_layer).uniq
    @total_sys = @systems.count
    @quads = Quadrant.generate(total_sys: @total_sys, assess_total: @systems.map(&:tq_fq_quadrant).count {|q| Quadrant.valid?(q)} )
  end

  def process
    @systems.each do |system|
      get_quad(system.tq_fq_quadrant).add(system: system)
    end
  end
  
  def get_quad(quad)
    q = @quads.find {|q| q.position == Quadrant.get_name(quad)}
    q ? q : raise    
  end
  
  def total_count
    @quads.inject(0) {|ct, q| ct += q.ct}
  end
  
  def position(quad)
    @quads.find {|q| q.quad_position == quad}
  end

  
  
end