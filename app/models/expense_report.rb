# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ExpenseReport < ActiveRecord::Base
  has_many :er_items
  belongs_to :user
end
