# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class QItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :quotation
  acts_as_list :scope => :quotation_id
end
