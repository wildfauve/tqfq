class SystemImportHandler
  
  attr_accessor :exceptions
  
  include Wisper::Publisher  
  
  def initialize(path: nil, systems: nil)
    @systems = systems
    @path = path
    self
  end
  
  def process
    if @path
      f = File.open(@path, 'r')
      tokens = tokenise(f.gets)
      f.each {|line| System.create_or_update(line: line.chomp, tokens: tokens)}
    else
      tokens = tokenise(@systems.shift)
      @systems.each do |system|
        t = tokens.dup
        System.create_or_update(system: system, tokens: t)
      end
    end
    publish(:successful_import_event, self)
  end
  
  def add_ref_binding(refs: nil, dummy: false)
    @exceptions = []
    refs.each do |ref|
      if !ref[3].nil? # there is a system mapping
        ref_model = ReferenceModel.where(name: ref[1]).first
        if !ref_model
          @exceptions << {exception: "ref model not found", ref: ref}
        end
        systems = ref[3].split(/\n/)
        systems.each do |sys_name|
          sys_name.gsub!(/^\s/, "")
          sys_name.gsub!(/\s$/, "")
          system = System.where(name: sys_name).first
          if !system
            @exceptions << {exception: "system not found", ref: ref, system: sys_name}
          else
            system.add_reference_model_binding(ref: ref_model) if !dummy
          end
        end
      end
    end
  end
  
  def tokenise(header)
    if header.is_a? Array
      header.inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    else
      header.split("|").inject([]) {|out, h| out << h.downcase.gsub(" ", "_").to_sym}
    end
  end
  
end