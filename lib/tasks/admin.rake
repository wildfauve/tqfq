namespace :admin do
  desc "Load Systems from CSV"
  task system_load: :environment do
    #System.all.delete
    systems = CSV.read('lib/tasks/ent_systems.csv')
    #systems = CSV.read('lib/tasks/systems_2.csv')    
    #systems = CSV.read('lib/tasks/dia_current_state.csv')    
    handler = SystemImportHandler.new(systems: systems)
    handler.process
  end

  desc "Load BIAN Reference Model"
  task bian_load: :environment do
    elements = CSV.read('lib/tasks/bian_features.csv')
    #ReferenceModel.all.delete
    handler = ReferenceModelImportHandler.new(ref: elements)
    handler.process
  end

  desc "Add Projects to BIAN Services"
  task bian_projects: :environment do
    elements = CSV.read('lib/tasks/bian_projects.csv')
    handler = ReferenceModelImportHandler.new(ref: elements)
    handler.process_projects
  end


  desc "Load Info Model"
  task info_model: :environment do
    elements = CSV.read('lib/tasks/info_model.csv')
    handler = InfoModelImportHandler.new(info: elements)
    handler.process
  end

  desc "CRUD Assessment"
  task crud_mapping: :environment do
    elements = CSV.read('lib/tasks/info_model_crud.csv')
    handler = InfoModelImportHandler.new(info: elements)
    handler.crud_mapping
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
    compare = Comparison.new.bian_system(matrix: true)
    compare.to_csv(file: "system_to_service_domain")
  end

  desc "BIAN to System Mapping with TQFQ"
  task map_bian_system: :environment do
    compare = Comparison.new.bian_system(matrix: false)
    compare.to_csv(file: "mapping_system_to_service_domain")
  end

  
  task tq_fq_rate: :environment do
    #compare = Comparison.new.tqfq_dimension(prepare_csv: true)
    compare = Comparison.new.tqfq_dimension.prepare_tqfq_csv.to_csv(file: "tqfq")
  end

  task replace: :environment do
    compare = Comparison.new.replacements.to_csv(file: "replacements")
  end
  
  task tq_fq_point: :environment do
    compare = Comparison.new.tq_fq_point_ct
    compare.to_csv(file: "tq_fq_points")
  end

  task tq_fq_point_to_quad: :environment do
    compare = Comparison.new.tq_fq_point_ct(grain: :quad)
    compare.to_csv(file: "tq_fq_quad")
  end

  task customer_systems: :environment do
    s = System.all.select {|v| v.maintain_customer == "Y"}
    CSV.open("lib/tasks/customer_systems.csv", 'w') do |csv|
      s.each do |system|
        row = [system.name, system.description_use]
        csv << row
      end
    end
    
  end
  
  


  
end
