# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ProductLinesController < ApplicationController

  def move_up
    line = ProductLine.find(params[:id])
    line.move_higher
    redirect_to :controller => 'products',
		:action => 'edit_options', :id => line.product_id
  end

  def move_down
    line = ProductLine.find(params[:id])
    line.move_lower
    redirect_to :controller => 'products',
		:action => 'edit_options', :id => line.product_id
  end

end
