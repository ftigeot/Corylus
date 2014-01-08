# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class CartItem
  attr_accessor	:product_id
  attr_accessor	:qty
  attr_reader	:options

  def initialize( product_id )
    @product_id = product_id
    # By setting qty to 0, the product is not displayed in the cart
    # It nevertheless allows to register choosen option values
    @qty = 0
    init_options
  end

  # Initialize options for this product line with default values
  # This allows lines to be displayed in the right order in quotations
  # and other documents.
  def init_options
    product = Product.find( @product_id )
    @options = []
    options = product.options
    for o in options
      option = {
        'option_id' => o.id,
        'value_id' => o.default_value,
        'qty' => @qty
    }
    @options << option
    end
  end

  # Update an option value for this product line
  # If the option doesn't exist yet, it is created
  def set_optval( option_id, value_id, qty )
    option = @options.find { |o| o['option_id'] == option_id }
    if option.nil?
      option = {
	'option_id' => option_id,
	'value_id' => value_id,
	'qty' => qty
      }
      @options << option
    else
      option['value_id'] = value_id
       option['qty'] = qty
    end
  end

  # Price of a product line with its eventual options
  def price
    product = Product.find( product_id )
    tmp_price = product.public_price
    for option in @options
      optval = OptionValue.find( option['value_id'] )
      qty = option['qty']
      qty = 1 if (qty.nil?)
      tmp_price += optval.cost * qty
    end
    return tmp_price
  end

end
