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
