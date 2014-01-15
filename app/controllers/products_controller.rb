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

class ProductsController < ApplicationController

  def show
    @product = Product.find(params[:id])
    @cart = session[:cart] || Cart.new
    @category = @product.category
    @options = @product.options
    @product_suppliers = @product.product_suppliers
    @options_cost = options_cost
    @price = total_price
  end

  def new
    @categories = Category.find :all, :order => 'name'
    @product = Product.new
    @product.category = Category.find( params[:category] )
    @vat_rates = VatRate.find :all
  end

  def create
    @product = Product.new(params[:product])
    @product.code = nil if (@product.code == '')
    if @product.save
      @product.move_to_bottom
      flash[:notice] = 'Produit créé avec succès'
      redirect_to :action => 'show', :id => @product
    else
      @categories = Category.find :all
      render :action => 'new'
    end
  end

  def zclone
    @product = Product.find(params[:id])
    @clone = @product.clone
    @clone.name = 'Clone de ' + @clone.name
    @clone.created_on = Date.today
    @clone.salable = false
    if @clone.save
      @clone.move_to_bottom
      flash[:notice] = 'Produit cloné avec succès'
    else
      flash[:notice] = 'Echec du clonage'
    end
    show
    render :action => 'show', :id => @clone.id
  end

  def edit
    @categories = Category.find :all, :order => 'name'
    @product = Product.find(params[:id])
    @category = @product.category
    @selcat = @product.category.id
    @product_suppliers = @product.product_suppliers
    @vat_rates = VatRate.find :all
  end

  # Comme pour edit_options, un onglet de edit
  def edit_components
    edit
    @components = @product.components

    # Only display (sub)categories with existing "simple" products, ie
    # products without any option or component
    @categories = Category.find_by_sql ['
    	SELECT categories.* FROM categories
    	WHERE id IN (
    		SELECT DISTINCT category_id FROM products
    		WHERE obsolete = FALSE
    		AND id NOT IN (SELECT DISTINCT product_id FROM product_lines)
    		AND id NOT IN (SELECT DISTINCT owner_id FROM components)
    	)
    	ORDER BY name']
  end

  def browse_next_ajax
    @cat = Category.find(params[:id])
    @cats = @cat.children if @cat
    if (@cats && @cats.size > 0)
      render :partial => 'shared/select_category', :layout => false
    else
      @products = Product.find :all,
	:conditions => ["category_id = ? and obsolete = false", @cat.id],
	:order => 'name'
      render :partial => 'shared/select_product', :layout => false
    end
  end

  # Displays "simple" products, ie products without any option or
  # component.
  def ajax_browse_products
    @cat = Category.find(params[:id])
    @products = Product.find_by_sql ['
	SELECT products.* FROM products
	WHERE obsolete = FALSE
	AND category_id = ?
	AND id NOT IN (SELECT DISTINCT product_id FROM product_lines)
	AND id NOT IN (SELECT DISTINCT owner_id FROM components)
	ORDER by name', @cat.id]
    render :partial => 'shared/select_product', :layout => false
  end

  def ajax_select_product
    @selected_product = Product.find(params[:id])
    render :partial => 'shared/product_selected', :layout => false
  end

  def update
    edit
    old_category = @product.category
    @product.code = nil if (@product.code == '')
    if @product.update_attributes(params[:product])
      flash[:notice] = 'Product was successfully updated.'
      redirect_to :action => 'show', :id => @product
    else
      render :action => 'edit'
    end
    @product.move_to_bottom if (@product.category != old_category)
  end

  # On peut considérer ça comme un onglet de edit
  # C'est uniquement pour ne pas trop alourdir la page qu'il y une vue
  # séparée
  def edit_options
    edit
    @product_lines = ProductLine.find :all,
	:conditions => ['product_id = ?', @product.id], :order => :position

    # Options non utilisées par le produit
    @unused_options = Option.find_by_sql ['
	SELECT DISTINCT o.* FROM options o
		WHERE o.id NOT IN (
			SELECT option_id FROM product_lines
			WHERE option_id IS NOT NULL
			AND product_id = ?
		)
	ORDER BY o.description', @product.id]
  end

  # Met à jour les lignes de description produit
  def update_lines
    @product = Product.find(params[:id])
    @product_lines = ProductLine.find :all,
	:conditions => ['product_id = ?', @product.id], :order => :position

    ActiveRecord::Base.transaction do
      @product_lines.each do |pl|
        if (pl.option_id.nil?)
          # 1. Cas d'une ligne de texte simple
          new_description = params[:line][pl.id.to_s]['description']
          new_qty = params[:line][pl.id.to_s]['qty']
          pl.update_attribute :description, new_description
          pl.update_attribute :qty, new_qty
        else
          # 2. Cas d'une ligne d'option
          max_qty = params[:line][pl.id.to_s]['max_qty']
          pl.update_attribute :max_qty, max_qty 
        end
      end
    end

    redirect_to :action => 'edit_options', :id => @product.id
  end

  def destroy
    Product.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def new_supplier
    @product = Product.find(params[:id])
    @fournisseurs = Supplier.find :all, :order => 'name'
  end

  def add_fournisseur
    @product = Product.find(params['product_id'])
    @supplier = Supplier.find(params['fournisseur_id'])

    @ps = ProductSupplier.new
    @ps.product_id = @product.id
    @ps.supplier_id = @supplier.id
    @ps.ref_fournisseur = params['ref']
    @ps.price = params['price']

    if @ps.save
      flash[:notice] = 'La référence fournisseur a été ajoutée.'
      redirect_to :action => 'show', :id => @product.id
    else
      flash[:notice] = "La référence fournisseur n'a pas pu être ajoutée."
      @fournisseurs = Supplier.find :all, :order => 'name'
      render :action => 'new_supplier', :id => @product.id
    end
  end

  def edit_supplier
    @ps = ProductSupplier.find( params[:id] )
    @product = @ps.product
    @supplier = @ps.supplier
  end

  def update_supplier
    @ps = ProductSupplier.find( params[:id] )
    @product = @ps.product
    @ps.price = params['price']
    @ps.ref_fournisseur = params['ref_fournisseur']
    @ps.save!
    flash[:notice] = 'Prix mis à jour.'
    redirect_to :action => 'show', :id => @product.id
  end

  def add_option
    @product = Product.find( params[:id] )
    option = Option.find( params[:option_id] )
    product_line = ProductLine.new
    product_line.product = @product
    product_line.option = option
    product_line.max_qty = 1
    product_line.save!
    redirect_to :action => 'edit_options', :id => @product.id
  end

  def remove_option
    @product = Product.find( params[:id] )
    Option.delete( params[:option] )
    redirect_to :action => 'edit_options', :id => @product.id
  end

  def new_component
    @product = Product.find( params[:id] )
    selected_product = Product.find( params[:selected_product][:id] )
    @component = Component.new
    @component.owner_id = @product.id
    @component.product_id = selected_product.id
    @component.qty = 1
    if (@component.save)
      @component.move_to_bottom
    end
    edit_components
    render :action => 'edit_components', :id => @product.id
  end

  def search
    @query = params[:query]
    @products = Product.search( @query )
    render :controller => 'category', :action => 'list'
  end

  # Crée un nouveau produit composé et lui attribue un numéro de série
  # La quantité en stock de chaque composant est diminuée
  def build
    @product = Product.find( params[:id] )
    @components = @product.components
    @options = @product.options
    @cart = find_cart
    cart_item = @cart.items.find { |i| i.product_id == @product.id }
    item_list = []
    # FIXME: pas de choix d'entrepot
    location = Location.find :first, :order => 'name'

    # do nothing if it a simple product
    return if ((@components.empty?) && (@options.empty?))

    # 1. manage components inventories
    # FIXME: should prepare transaction and only commit if everything is ok
    for component in @components
      item = CartItem.new(@product.id)
      item.product_id = component.product_id
      item.qty = component.qty
      item_list << item
    end

    # 2. list selected options
    for option in @options
      # Impossible to create a product if it is a complex one, with
      # different options and none are currently selected
      if (cart_item.options.nil?)
        flash[:notice]  = 'To create a new instance of this product, '
        flash[:notice] += 'choose the needed options first'
        return
      end

      for option_value in cart_item.options
        if (option_value['option_id'] == option.id)
          sel_opt_vid = option_value['value_id']
          selected_qty = option_value['qty']
        end
      end
      if ((sel_opt_vid.nil?) || (selected_qty.nil?))
        flash[:notice] = 'No selected option value found for option'
        return
      end
      # option value found
      sel_optval = OptionValue.find(sel_opt_vid)
      # does it correspond to a product ?
      if (!sel_optval.product_id.nil?)
        # yes => add to list
        item = CartItem.new(@product.id)
        item.product_id = sel_optval.product_id
        item.qty = selected_qty
        item_list << item
      end
    end

    # 3. Create a new complex product description
    mg = ManufacturedGood.new
    ManufacturedGood.transaction do
      mg.product_id = @product.id
      mg.save!
      # 4. Update inventory levels
      for item in item_list
        mi = MgItem.new
        mi.owner_id = mg.id
        mi.product_id = item.product_id
        mi.qty = item.qty
        mg.mg_items << mi
        Stock.update_qty( location.id, item.product_id, -item.qty )
      end
      Stock.update_qty( location.id, @product.id, +1 )
      mg.save!
    end

    flash[:notice] = 'Un nouveau produit a été assemblé'
    redirect_to :action => 'show', :id => @product.id
  end

  def add_description_line
    @product = Product.find( params[:id] )
    product_line = ProductLine.new
    product_line.product = @product
    product_line.option_id = nil
    product_line.max_qty = nil
    product_line.description = ''
    product_line.qty = nil
    product_line.save!
    redirect_to :action => 'edit_options', :id => @product.id
  end

private

  # Calcule le prix des options sélectionnées
  def options_cost
    tmp_cost = 0.00

    # 1. trouve le cart_item avec le product_id du produit
    cart_item = @cart.items.find { |i| i.product_id == @product.id }

    # si cart_item.nil? est vrai, on continue qd-meme
    for option in @product.options

      # 2. Utilise des valeurs par défaut raisonnables si le produit n'a
      # pas encore été configuré
      sel_opt_vid = option.default_value
      selected_qty = 1

      # 3. trouve le couple (option_id,value_id) avec l'option_id en
      # cours de test
      unless cart_item.nil?
        for option_value in cart_item.options
          if (option_value['option_id'] == option.id)
            sel_opt_vid = option_value['value_id']
            selected_qty = option_value['qty']
          end
        end
      end
      selected_value = OptionValue.find( sel_opt_vid )
      tmp_cost += selected_qty * selected_value.cost
    end
    return tmp_cost
  end

  # Calcule le prix total du produit
  def total_price
    price  = @product.public_price
    price += options_cost
    return price
  end

end
