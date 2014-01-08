# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class OptionValue < ActiveRecord::Base
  belongs_to	:option
  acts_as_list	:scope => :option
  belongs_to	:product

  def cost
    if (self.product_id)
      return self.product.public_price
    else
      return self.price
    end
  end

  def description
    if (self.product_id)
      return self.product.description
    else
      return self.name
    end
  end

end
