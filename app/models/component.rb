# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Component < ActiveRecord::Base
  belongs_to :owner, :class_name => 'Product'
  belongs_to :product
  acts_as_list :scope => :owner

end
