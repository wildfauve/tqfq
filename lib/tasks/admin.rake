namespace :admin do
  desc "Load Systems from CSV"
  task system_load: :environment do
    #System.all.delete
    systems = CSV.read('lib/tasks/systems_2.csv')
    handler = SystemImportHandler.new(systems: systems)
    handler.process
  end

  desc "Load BIAN Reference Model"
  task bian_load: :environment do
    elements = CSV.read('lib/tasks/bian.csv')
    #ReferenceModel.all.delete
    handler = ReferenceModelImportHandler.new(ref: elements)
    handler.process
  end

  desc "Load Mapping of Systems to BIAN"
  task bian_system: :environment do
    ref_bindings = CSV.read('lib/tasks/bian_mapping.csv')
    handler = SystemImportHandler.new
    handler.add_ref_binding(refs: ref_bindings, dummy: false)
    puts "Exceptions: #{handler.exceptions.count}"
    handler.exceptions.map {|e| e[:system]}.uniq.each {|es| puts "System not in Systems Register: #{es} "}
    handler.exceptions.map {|e| e[:ref_model]}.uniq.each {|er| puts "Reference Model Name Not found: #{er} "}
  end
  
  desc "BIAN to System Matrix"
  task matrix_bian_system: :environment do
    compare = Comparison.new.bian_system
    compare.to_csv(file: "system_to_service_domain")
    puts compare.inspect
  end
  
  task tq_fq_rate: :environment do
    compare = Comparison.new.tqfq_dimension
    compare.to_csv(file: "tqfq")
  end

  task replace: :environment do
    compare = Comparison.new.replacements
    compare.to_csv(file: "replacements")
  end
  
  task tq_fq_point: :environment do
    compare = Comparison.new.tq_fq_point_ct
    compare.to_csv(file: "tq_fq_points")
  end


  
end
