# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ComponentsController < ApplicationController

  def list
    @product = Product.find(params[:owner_id])
    @components = @product.components
  end

  def update_positions
    @owner = Product.find(params[:owner_id])
    Component.transaction do
      ActiveRecord::Base.record_timestamps = false
      @owner.components.each do |component|
        component.update_attribute( :position,
		params[:sortable].index(component.id.to_s) + 1 )
      end
      ActiveRecord::Base.record_timestamps = true
    end
    list
    render :action => 'list', :layout => false
  end

  def update
    @owner = Product.find(params[:owner_id])
    Component.transaction do
      @owner.components.each do |component|
        old_qty = component.qty
        new_qty = params[:component][component.id.to_s]['qty'].to_i
        component.update_attribute :qty, new_qty if (new_qty != old_qty)
      end
    end
    redirect_to :controller => 'products',
		:action => 'edit_components',
		:id => @owner.id
  end

end
