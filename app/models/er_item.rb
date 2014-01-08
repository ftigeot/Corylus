# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ErItem < ActiveRecord::Base
  belongs_to	:expense_report, :foreign_key => 'er_id'
end
