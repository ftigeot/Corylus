# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Reception < ActiveRecord::Base
  belongs_to	:supplier
  belongs_to	:supplier_order
  belongs_to	:location
  has_many	:reception_items, :order => 'id'
end
