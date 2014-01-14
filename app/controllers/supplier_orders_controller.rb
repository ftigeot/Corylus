# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class SupplierOrdersController < ApplicationController

  def new
    @cart = session[:cart]
    @items = @cart.items
    supplier_list = nil
    product_list = []

    if @items.empty?
      flash[:notice] = 'Le panier est vide.'
      redirect_to :controller => 'gescom', :action => 'display_cart'
    else
      @order = SupplierOrder.new

      # On détermine la liste des fournisseurs des produits du panier
      # 1. récupération de la liste des produits
      for item in @items
        product_list << item.product_id
      end
      
      # 2. récupération de la liste des fournisseurs de ces produits
      @suppliers = Supplier.find_by_sql ['
      	SELECT DISTINCT partners.* FROM partners
      	INNER JOIN product_suppliers ON partners.id = product_suppliers.supplier_id
      	WHERE partners.is_supplier IS TRUE
      	AND product_id IN (?)
      	ORDER BY partners.name', product_list]
    end
  end

  def create
    @cart = session[:cart]
    @order = SupplierOrder.new(params[:order])
    @order.shipping_address_id = Setting.shipping_address_id
    supplier = @order.supplier
    for item in @cart.items
      product = Product.find( item.product_id )
      soi = SoItem.new
      soi.product_id = product.id
      soi.ref = sp_ref( supplier, product )
      soi.description = product.description
      soi.price = sp_price( supplier, product )
      soi.qty = item.qty
      @order.so_items << soi
    end

    if @order.save
      @cart.empty!
      redirect_to :action => 'show', :id => @order.id
    else
      render :action => 'new'
    end
  end

  def list
    @orders = SupplierOrder.find :all, :order => 'id DESC'
  end

  def list_open
    # We only care about orders less than one year old
    @orders = SupplierOrder.find :all, :order => 'id DESC',
    	:conditions => ['created_on > ?', Date.today - 365]
    @orders.delete_if{ |o| o.fully_received? }
    render :action => 'list'
  end

  def show
    @company_name = Setting.company_name
    @order = SupplierOrder.find(params[:id])
    @items = @order.so_items
    @receptions = @order.receptions
    h = request.host
    filename = "Bon-commande-" + @order.official_id.to_s + ".pdf"
    @pdf_url = URI.parse(TOMCAT_BASE +
	"BonCommande.pdf?host=#{h}&id=#{@order.id}&filename=#{filename}").to_s
  # Required by XML documents
    @supplier = @order.supplier
    @supplier_address = @supplier.primary_address
    @billing_address = Address.find( Setting.billing_address_id )
    @delivery_address = @order.shipping_address
    # FIXME: No session if called from a Tomcat servlet
    if (@user.nil?)
      @user = User.find(2)
    end
    @contact_email = Setting.contact_email
  end

  def edit
    show
    @suppliers = Supplier.find( :all, :order => 'name' )

    @shipping_addresses = []
    default_sa = Address.find(Setting.shipping_address_id)
    @shipping_addresses << default_sa
    customers = Customer.find :all, :order => 'name'
    for customer in customers
      @shipping_addresses << customer.shipping_address
    end

  end

  def update
    @order = SupplierOrder.find(params[:id])
    @so_items = SoItem.find :all, :conditions => ['supplier_order_id = ?', params[:id]]
    @so_items.each do |so_item|
      so_item.update_attributes( params[:item]["#{so_item.id}"] )
    end
    if @order.update_attributes(params[:order])
      flash[:notice] = 'Order was successfully updated.'
    end
    redirect_to :action => 'edit', :id => @order.id
  end

  def destroy_item
    item = SoItem.find(params[:id])
    supplier_order_id = item.supplier_order_id
    item.destroy
    redirect_to :action => 'edit', :id => supplier_order_id
  end

  def new_line
    @order = SupplierOrder.find(params[:id])
    so_item = SoItem.new
    so_item.supplier_order_id = @order.id
    so_item.description = ''
    so_item.price = 1.00
    unless so_item.save
      flash[:notice] = "Echec de l'ajout d'une nouvelle ligne"
    end
    redirect_to :action => 'edit', :id => @order.id
  end

  def load_cart
    @cart = find_cart
    @order = SupplierOrder.find(params[:id])
    so_items = SoItem.find :all,
    	:conditions => ['
    		supplier_order_id = ?
    		and product_id IS NOT NULL', @order.id ],
    	:order => 'position'
    for item in so_items
      @cart.add_product( item.product )
      @cart.update_qty( item.product_id, item.qty )
    end
    redirect_to :controller => 'gescom', :action => 'display_cart'
  end

private

  # renvoie la référence du produit chez le fournisseur en question
  # La taille du champ est limitée à 16 caractères
  def sp_ref( supplier, product )
    logger.info "sp_ref(): supplier = #{supplier.id}, product = #{product.id}"
    ps = ProductSupplier.find :first,
	:conditions => ['product_id = ? and supplier_id = ?', product.id, supplier.id]
    return nil if ps.nil?
    return ps.ref_fournisseur.slice(0..15)
  end

  def sp_price( supplier, product )
    ps = ProductSupplier.find :first,
	:conditions => ['product_id = ? and supplier_id = ?', product.id, supplier.id]
    return 0 if ps.nil?
    return ps.price
  end

end
