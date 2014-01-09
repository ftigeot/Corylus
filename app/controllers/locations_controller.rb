# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class LocationsController < ApplicationController

  def list
    @locations = Location.find :all, :order => 'name'
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new( params[:location] )
    if @location.save
      flash[:notice] = 'Produit créé avec succès'
      redirect_to :action => 'list', :id => @location.id
    else
      render :action => 'new'
    end
  end

  def edit
    @location = Location.find( params[:id] )
  end

  def update
    @location = Location.find( params[:id] )
    if @location.update_attributes( params[:location] )
      flash[:notice] = 'Entrepot mis à jour avec succès'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

end
