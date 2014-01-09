# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class InterventionsController < ApplicationController

  def new
    @intervention = Intervention.new
    @customers = Customer.find :all, :order => 'name'
  end

  def create
    @intervention = Intervention.new(params[:intervention])

    Intervention.transaction do
      if @intervention.save
        flash[:notice] = 'New intervention registered.'
      else
        flash[:notice] = 'Failed to create a new intervention.'
      end
    end
    redirect_to :action => 'list'
  end

  def edit
    @intervention = Intervention.find(params[:id])
    @customers = Customer.find :all
  end

  def update
    @intervention = Intervention.find(params[:id])
    if @intervention.update_attributes(params[:intervention])
      flash[:notice] = 'Intervention record updated.'
      redirect_to :action => 'show', :id => @intervention.id
    else
      render :action => 'edit'
    end
  end

  def list
    @interventions = Intervention.find :all, :order => 'created_at'
  end

  def show
    @intervention = Intervention.find(params[:id])
  end

end
