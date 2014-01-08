# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ProductSupplier < ActiveRecord::Base
  belongs_to	:product
  belongs_to	:supplier

  validates_numericality_of :price, :greather_than => 0,
	:message => "isn't a positive number"
end
