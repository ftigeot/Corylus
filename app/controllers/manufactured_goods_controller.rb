# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ManufacturedGoodsController < ApplicationController

  def list
    @mgs = ManufacturedGood.find :all, :order => 'created_on DESC'
  end

  def show
    @mg = ManufacturedGood.find(params[:id])
    @mis = @mg.mg_items 
  end

end
