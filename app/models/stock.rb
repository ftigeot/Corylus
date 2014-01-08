# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Stock < ActiveRecord::Base
  belongs_to :product
  belongs_to :location

  def self.update_qty( location_id, product_id, delta )
    
    # 0. Protect everything with a transaction
    Stock.transaction do
      # 1. Find an existing entry
      stock = Stock.find :first,
      	:conditions => ["location_id = ? and product_id = ?",
      	location_id, product_id]
      # 1. Or create a new one
      if (stock.nil?)
        stock = Stock.new
        stock.location_id = location_id
        stock.product_id = product_id
        stock.qty = 0
      end

      # 2. Update the registered quantity
      stock.qty += delta

      # 3. If the final quantity is zero, delete the line
      if (stock.qty == 0)
        stock.destroy
      else
        stock.save!
      end
    end

  end

  def self.deliverable(product_id)
    return Stock.sum 'qty', :conditions => ['product_id = ?', product_id]
  end

end
