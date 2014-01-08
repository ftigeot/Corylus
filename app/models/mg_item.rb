# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class MgItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :manufactured_goods, :foreign_key => 'owner_id'
end
