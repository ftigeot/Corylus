# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ProductLine < ActiveRecord::Base
  belongs_to	:product
  belongs_to	:option
  acts_as_list	:scope => :product
end
