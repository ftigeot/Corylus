# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class SoItemsController < ApplicationController

  def move_up
    item = SoItem.find(params[:id])
    item.move_higher
    redirect_to :controller => 'supplier_orders', :action => 'edit', :id => item.supplier_order_id
  end

  def move_down
    item = SoItem.find(params[:id])
    item.move_lower
    redirect_to :controller => 'supplier_orders', :action => 'edit', :id => item.supplier_order_id
  end

end
