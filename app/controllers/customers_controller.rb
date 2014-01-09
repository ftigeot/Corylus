# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class CustomersController < ApplicationController

  def list
    @customers = Customer.find :all, :order => 'name'
  end

end
