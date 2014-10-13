class ComparisonsController < ApplicationController
  
  def tqfq
    compare = Comparison.new
    compare.subscribe self
    compare.tqfq_dimension
  end
    
  def tq_fq_dimension_done(compare)
    @compare = compare
    render 'tqfq'
  end
  
end