# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class DsItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :delivery_slip
  belongs_to :q_item
end
