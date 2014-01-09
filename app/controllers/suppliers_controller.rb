# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class SuppliersController < ApplicationController

  def list
    @fournisseurs = Supplier.find :all, :order => 'name'
  end

end
