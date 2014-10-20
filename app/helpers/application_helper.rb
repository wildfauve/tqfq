module ApplicationHelper
  
  def set_up_system(system)
    prop_source = System.first
    sys = System.new
    prop_source.properties.each {|p| sys.properties << Property.new.add_attrs(name: p.name) }
    sys
  end
  
  def determine_alert_from_tqfq(system)
    case system.tq_fq_quadrant
    when "replace"
      "alert-danger"
    when "keep"
      "alert-success"
    else
      "alert-warning"
    end 
  end
  
end
