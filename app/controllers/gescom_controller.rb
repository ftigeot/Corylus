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

class GescomController < ApplicationController

  def add_to_cart
    product = Product.find(params[:id]) 
    @cart = find_cart
    @cart.add_product(product)
    redirect_back 'Product added to the shopping cart'
    # TODO: toujours renvoyer vers la page produit de départ
  rescue
    logger.error("Attempt to access invalid product #{params[:id]}")
    redirect_back 'Produit invalide'
  end

  def update_options
    @cart = find_cart
    product = Product.find(params[:product][:id]) 
    action = params[:commit]

    if (action == 'Add to cart with selected options')
      add_to_cart_with_options( product )
    end

    if (action == 'Recalculate price')
      @cart.set_product_options( product.id, params[:options].values )
    end 

    redirect_to :controller => 'products', :action => 'show', :id => product
  end

  def display_cart
    @cart = find_cart
    @items = @cart.items
  end

  def empty_cart
    @cart = find_cart
    @cart.empty!
    redirect_back 'Cart is now empty'
  end

  def remove_items
    @cart = find_cart
    @items = @cart.items
    product = Product.find( params[:product_id] ) 
    @cart.del_product( product )
    render :action => 'display_cart'
  end

  # update_cart(): met à jour les quantités de produit dans le panier
  def update_cart
    @cart = find_cart
    @items = @cart.items

    for item in @items do
      qty = params[:item]["#{item.product_id}"].to_i
      @cart.update_qty( item.product_id, qty )
    end

    render :action => 'display_cart'
  end

  def new_quotation
    @cart = find_cart
    @items = @cart.items
    @customers = Customer.find :all, :order => 'name ASC' 
    if @items.empty?
      flash[:notice] = 'Le panier est vide.'
      redirect_to :action => 'display_cart'
    else
      @quotation = Quotation.new
    end
  end

  def save_quotation
    @cart = find_cart
    @quotation = Quotation.new( params[:quotation] )
    @quotation.user = User.find(session[:user_id])

    Quotation.transaction do
      @quotation.save!

      for ci in @cart.items
        # 1. Le produit proprement dit
        product = Product.find( ci.product_id )
        qi = QItem.new
        qi.quotation_id = @quotation.id
        qi.product_id = product.id
        qi.description = product.description
        qi.qty = ci.qty
        qi.price = product.public_price
        qi.vat = product.vat
        qi.save!
  
        qi.price += product_lines_to_quotation( @quotation.id, ci )
        qi.save!
      end
    end # Transaction

    if @quotation.save
      @cart.empty!
      redirect_to :controller => 'quotations', :action => 'list'
    else
     @customers = Customer.find :all, :order => 'name ASC' 
      render( :action => 'new_quotation' )
    end
  end

  # Charge le panier depuis un devis existant
  def load_cart
    @cart = find_cart
    @quotation = Quotation.find( params[:id] )
    @cart.empty!
    q_items = QItem.find_by_sql ["
    	select * from q_items where quotation_id = ? and product_id IS NOT NULL
    	order by position", @quotation.id ]
    for item in q_items
      @cart.add_product( item.product )
      @cart.update_qty( item.product_id, item.qty )
    end
    display_cart
    render :action => 'display_cart'
  end

private

  def add_to_cart_with_options( product )
    @cart.add_product( product )
    @cart.set_product_options( product.id, params[:options].values )
    flash[:notice] = 'The product and its options has been added to the cart.'
  rescue
    logger.error("add_to_cart_with_options: failed for product #{product.id}")
    flash[:notice] = "add_to_cart_with_options: Couldn't add to the cart"
  end

  # Ajoute les lignes de détail d'un produit à un devis
  # entrées:
  #   - quotation_id: le numéro du devis en cours de création
  #   - cart_item: la ligne du panier qui correspond au produit en cours
  #   de traitement
  # sortie: prix des options
  def product_lines_to_quotation( quotation_id, cart_item )
    @cart = find_cart
    quotation = Quotation.find(quotation_id)
    product = Product.find( cart_item.product_id)
    options_price = 0

    return 0 if (product.product_lines.empty?)

    Quotation.transaction do
      # Traitement des lignes associées au produit
      for line in product.product_lines
        qi = QItem.new
        qi.quotation_id = quotation.id
        if (line.option_id.nil?)
          # cette ligne est un texte simple
          qi.description = line.description
          qi.qty = line.qty
        else

          # cette ligne est une option produit  
          option = Option.find( line.option_id )
          for opt in cart_item.options
            if (opt['option_id'] == option.id)
              val = OptionValue.find( opt['value_id'] )
              qi.qty = opt['qty']
              qi.description = val.description
              options_price += val.cost * qi.qty
              break
            end
          end

        end
        qi.save!
      end
    end # transaction

    return options_price
  end

end
