# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class SoItem < ActiveRecord::Base
  belongs_to	:supplier_order
  belongs_to	:product
  acts_as_list	:scope => :supplier_order

  def total_price
    if (self.qty && self.price)
      return self.qty * self.price
    else
      return nil
    end
  end

end
