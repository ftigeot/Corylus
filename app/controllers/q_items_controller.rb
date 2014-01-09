# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class QItemsController < ApplicationController

  def show
    @q_item = QItem.find(params[:id])
  end

  def new
    @q_item = QItem.new
  end

  def create
    @q_item = QItem.new(params[:q_item])
    if @q_item.save
      flash[:notice] = 'QItem was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @q_item = QItem.find(params[:id])
  end

  def update
    @q_item = QItem.find(params[:id])
    if @q_item.update_attributes(params[:q_item])
      flash[:notice] = 'QItem was successfully updated.'
      redirect_to :action => 'show', :id => @q_item
    else
      render :action => 'edit'
    end
  end

  def destroy
    QItem.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def move_up
    @q_item = QItem.find(params[:id])
    @q_item.move_higher
    redirect_to :controller => 'quotations', :action => 'edit', :id => @q_item.quotation_id
  end

  def move_down
    @q_item = QItem.find(params[:id])
    @q_item.move_lower
    redirect_to :controller => 'quotations', :action => 'edit', :id => @q_item.quotation_id
  end

end
