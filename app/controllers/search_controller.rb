class SearchController < ApplicationController
  
  def show
    s = Search.new(params)
    s.subscribe(self)
    s.search
  end
  
  def show_tables_event(results)
    @results = results
    render 'search'
  end
  
end