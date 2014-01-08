# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

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
