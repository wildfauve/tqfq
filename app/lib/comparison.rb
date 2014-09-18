class Comparison
  
  attr_accessor :result
  
  def initialize
    self
  end
  
  def bian_system
    @matrix = []
    y_axis_input = ReferenceModel.where(level: :service_domain).sort {|a,b| a.token <=> b.token}  # TODO Sort by Parent and Parent
    x_axis_input = System.all
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
  
  def tqfq_dimension
    systems = System.all
    pace = systems.map(&:pace_layer).uniq
    #dim = sys.each_with_object(Hash.new(0)) { |tqfq,counts| counts[tqfq] += 1 }
    no_sys = systems.count
    #percent = dim.inject({}) {|ct, (k, v)| ct[k] = v/(no_sys.to_f); ct}
    
    dim = systems.each_with_object(Hash.new(0)) do |system, counts|
      system.tq_fq_quadrant.nil? ? tqfq = "Not Assessed" : tqfq = system.tq_fq_quadrant
      if counts[tqfq] != 0
        counts[tqfq][:ct] += 1
      else
        counts[tqfq] = {ct: 1}
      end
      counts[tqfq][system.pace_layer] ? counts[tqfq][system.pace_layer] += 1 : counts[tqfq][system.pace_layer] = 1
    end
    dim.each {|k, v| dim[k][:percent] = dim[k][:ct] / no_sys.to_f }  
    @matrix = [["TQFQ Quadrant", "Ct", "%"]]
    pace.each {|p| p ? @matrix[0] << p : @matrix[0] << "Not Assessed"}
    dim.each do |k, v| 
      row = [k, v[:ct], v[:percent]]
      pace.each {|p| v[p] ? row << v[p] : row << ""}
      @matrix << row
    end
    self
  end
  
  def replacements
    # Get all systems that need to be replaced
    #replaced = System.find_by_prop(prop: :tq_fq_quadrant, value: :replace).to_a
    #separate into SoR and others
    #part = replaced.partition {|sys| sys.pace_layer == "sor"}
    # Determine how many are replaced by SAP
    repl = []
    # determine the SAP Replacement
    repl << coverage(systems: System.all)
    #repl << coverage(systems: part[1])
    @result = repl.flatten
    
    @matrix = [["System", "Pace Layer", "TQ/FQ", "Target", "SAP Coverage", "BIAN Mapping Count", "Timeframe"]]
    @result.each {|sys| @matrix << [sys[:system], sys[:pace], sys[:tqfq], sys[:target], sys[:covered], sys[:map_ct], sys[:timeframe]]}
    self
  end
  
  def coverage(systems: nil)
    cover = []
    systems.each do |sys|
      decision = replace_decision(sys: sys)
      mapping = sys.reference_models.map(&:sap_mapping)
      map_ct = mapping.count
      mapping.delete("Y")
      mapping.empty? ? covered = 100 : covered =  (mapping.count.to_f / map_ct) * 100
      cover << {system: sys.name, pace: sys.pace_layer, tqfq: sys.tq_fq_quadrant, 
                covered: covered, map_ct: map_ct, target: decision[:target], timeframe: decision[:timeframe] }
    end
    cover
  end
  
  def replace_decision(sys: nil)
    return {target: "more info", timeframe: "more info"} if sys.tq_fq_quadrant.nil? && sys.pace_layer.nil?
    if sys.tq_fq_quadrant == "replace"
      timeframe = "medium"
      if sys.pace_layer == "sor"
        target = "SAP"
      else
        target = "New"
      end
    elsif sys.tq_fq_quadrant == "keep"
      if sys.pace_layer == "sor"
        target = "SAP"
        timeframe = "long"
      else
        target = "Keep"
      end
    else
      if sys.pace_layer == "sor"
        target = "SAP"
        timeframe = "long"
      else
        target = "Keep"
      end
    end
    {target: target, timeframe: timeframe}
  end
  
  def to_csv(file: nil)
    CSV.open("lib/tasks/#{file}.csv", 'w') do |csv|
      @matrix.each do |row| 
        csv << row
      end
    end
  end
  
  
end