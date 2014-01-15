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

class Cart
  attr_reader :items

  def initialize
    empty!
  end

  def add_product( product )
    # 1. Ensure the existence of a product line
    init_product(product.id)

    # 2. Increase its quantity by 1
    item = @items.find { |i| i.product_id == product.id }
    item.qty += 1
  end

  # Met à jour les options d'un produit
  def set_product_options( product_id, option_list )
    # 1. Create a product line
    init_product(product_id)

    # 2. Update options associated with this line
    for o in option_list
      option_id = o['id'].to_i
      value_id = o['value_id'].to_i
      qty = o['qty'].to_i
      set_product_option( product_id, option_id, value_id, qty )
    end
  end

  def del_product( product )
    # There must be only one entry per product line
    @items.each_index{ |i|
      @items.delete_at(i) if @items[i].product_id == product.id 
    }
  end
  
  def update_qty( product_id, qty )
    @items.each_index{ |i|
      @items[i].qty = qty if @items[i].product_id == product_id 
    }
  end

  def total_price
    subtotal = 0
    @items.each do |item|
      subtotal += item.price * item.qty
    end
    return subtotal
  end

  def empty!
    @items = []
  end

private

  # Initialize a product line if it doesn'tn already exist
  def init_product( product_id )
    item = @items.find { |i| i.product_id == product_id }
    if item.nil?
      item = CartItem.new( product_id )
      @items << item
    end
  end

  # Update a product option
  # The product and its options must already exist in the shopping cart
  def set_product_option( product_id, option_id, value_id, qty )
    @items.each{ |i|
      i.set_optval( option_id, value_id, qty ) if i.product_id == product_id
    }
  end

end
