class Comparison
  
  include Wisper::Publisher
  
  attr_accessor :result, :tqfq
  
  def initialize
    self
  end
  
  def bian_system
    @matrix = []
    y_axis_input = ReferenceModel.where(level: :service_domain).sort {|a,b| a.token <=> b.token}  # TODO Sort by Parent and Parent
    x_axis_input = System.system_type
    @matrix << x_axis_input.map(&:name).unshift(" ") 
    parent = nil
    y_axis_input.each do |bian|
      if parent.nil? || parent != bian.parent
        parent = bian.parent
        @matrix << [parent.token]
      end
      row = [bian.name]
      x_axis_input.each do |sys|
        sys.associated_with_model?(model: bian) ? row << "X" : row << ""
      end
      @matrix << row
    end
    self
  end
=begin  
  def tqfq_dimension(prepare_csv: false)
    quad = ["replace", "refactor", "keep", "enhance"]
    layers = ["sor", "sod", "soi"]
    systems = System.system_type
    pace = systems.map(&:pace_layer).uniq
    total_sys = systems.count
    assessed_sys = systems.map(&:tq_fq_quadrant).count {|q| quad.include?(q)} 
    @tqfq = systems.each_with_object(Hash.new(0)) do |system, counts|
      quad.include?(system.tq_fq_quadrant) ? tqfq = system.tq_fq_quadrant :  tqfq = "Not Assessed"
      if counts[tqfq] != 0
        counts[tqfq][:ct] += 1
      else
        counts[tqfq] = {ct: 1}
      end
      counts[tqfq][system.pace_layer] ? counts[tqfq][system.pace_layer] += 1 : counts[tqfq][system.pace_layer] = 1
    end
    @tqfq.each {|k, v| @tqfq[k][:percent_total] = @tqfq[k][:ct] / total_sys.to_f ; @tqfq[k][:percent_assessed] = @tqfq[k][:ct] / assessed_sys.to_f }  
    if prepare_csv
      @matrix = [["TQFQ Quadrant", "Ct", "% of total", "% of assessed"]]
      pace.each {|p| layers.include?(p) ? @matrix[0] << p : @matrix[0] << "Not Assessed"}
      @tqfq.each do |k, v| 
        row = [k, v[:ct], v[:percent_total], v[:percent_assessed]]
        pace.each {|p| v[p] ? row << v[p] : row << ""}
        @matrix << row
      end
    end
    publish(:tq_fq_dimension_done, self)
    self
  end
=end
  def tqfq_dimension
    @tqfq = Quality.new(systems: System.core(type: :all))
    @tqfq.process
    publish(:tq_fq_dimension_done, self)
    self  
  end
  
  def prepare_tqfq_csv
    @matrix = [["TQFQ Quadrant", "Ct", "% of total", "% of assessed"]]
    #pace.each {|p| layers.include?(p) ? @matrix[0] << p : @matrix[0] << "Not Assessed"}
    @tqfq.quads.each do |quad| 
      row = [quad.position, quad.ct, quad.tot_percent, quad.assess_percent]
      quad.count_dims.each do |dim|
        dim.each do |key, ct|
          row << key
          row << ct
        end
      end
      @matrix << row
    end
    self
  end
  
  def replacements
    repl = []
    repl << coverage(systems: System.system_type)
    @result = repl.flatten
    @matrix = [["System", "Pace Layer", "TQ/FQ", "Target", "SAP Coverage", "BIAN Mapping Count", "Timeframe"]]
    @result.each {|sys| @matrix << [sys[:system], sys[:pace], sys[:tqfq], sys[:target], sys[:covered], sys[:map_ct], sys[:timeframe]]}
    self
  end
  
  def coverage(systems: nil)
    cover = []
    systems.each do |sys|
      decision = replace_decision(sys: sys)
      #binding.pry if sys.name == "In-Touch"
      cover << {system: sys.name, pace: sys.pace_layer, tqfq: sys.tq_fq_quadrant, 
                covered: sys.sap_coverage, map_ct: sys.bian_map_ct, target: decision[:target], timeframe: decision[:timeframe] }
    end
    cover
  end
  
  def replace_decision(sys: nil)
    #return {target: "more info", timeframe: "more info"} if sys.tq_fq_quadrant.nil? && sys.pace_layer.nil?
    if sys.tq_fq_quadrant == "replace"
      timeframe = "T1"
      if sys.pace_layer == "sor"
        target = "SAP"
      else
        target = "New"
      end
    elsif sys.tq_fq_quadrant == "keep"
      if sys.pace_layer == "sor"
        target = "SAP"
        timeframe = "T2"
      else
        target = "Keep"
      end
    else
      if sys.pace_layer == "sor"
        target = "SAP"
        timeframe = "T2"
      else
        target = "Keep"
      end
    end
    {target: target, timeframe: timeframe}
  end
  
  def tq_fq_point_ct(grain: nil)
    systems = System.system_type
    @matrix = []
    systems.map(&:branch).uniq.unshift("ALL").each do |br|
      if br == "ALL"
        sys = systems
      else
        sys = systems.select {|s| s.branch == br }
      end
      point_dim(branch: br, systems: sys, grain: grain)
    end
    self
  end
  
  def point_dim(branch: nil, systems: nil, grain: nil)
    if grain == :quad
      system_points = systems.map(&:quad)
      points = system_points.uniq
    else
      system_points = systems.map(&:tq_fq_point)
      points = system_points.uniq      
    end
    total = system_points.count
    assessed = systems.inject(0) {|ct, sys| ct += 1 if sys.assessed?; ct}
    ct = {}
    system_points.each do |sp|
      if ct[sp]
        ct[sp][:ct] += 1
        ct[sp][:percent] = ct[sp][:ct] / assessed.to_f
      else
        ct[sp] = {ct: 1, percent: 1 / assessed.to_f}
      end
    end
    @matrix << [branch]
    @matrix << ["Point", "Count", "Percentage"]
    ct.each do |point, calc|
      @matrix << [point, calc[:ct], calc[:percent]]
    end
  end
  
  def to_csv(file: nil)
    CSV.open("lib/tasks/#{file}.csv", 'w') do |csv|
      @matrix.each do |row| 
        csv << row
      end
    end
  end
  
  
end