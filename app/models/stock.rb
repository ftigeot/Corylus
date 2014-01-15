# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

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
