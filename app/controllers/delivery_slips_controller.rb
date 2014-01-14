# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class DeliverySlipsController < ApplicationController

  def create
    @order = Order.find(params[:id])
    customer = @order.quotation.customer
    @delivery_slip = DeliverySlip.new
    @delivery_slip.order_id = @order.id
    @delivery_slip.address = customer.shipping_address
    DeliverySlip.transaction do
      @delivery_slip.save
      populate_dsitems( @delivery_slip )
      update_stock( @delivery_slip )
      if (@delivery_slip.ds_items.count > 0)
        if @delivery_slip.save
          flash[:notice] = 'Bon de livraison créé'
        else
          flash[:notice] = 'Echec de la création du bon de livraison'
          raise ActiveRecord::Rollback
        end
      else
        flash[:notice] = 'Aucun produit disponible - impossible de livrer'
        raise ActiveRecord::Rollback
      end
    end
    redirect_to :controller => 'orders', :action => 'show', :id => @order.id
  end

  def new
    @dslip = DeliverySlip.new
    @partners = Partner.find :all, :order => 'name'
  end

  # Bon de livraison sans devis
  # Peut être adressé à un partner en général et non pas seulement à un
  # customer.
  # Utile pour les RMA.
  def create_standalone
    @delivery_slip = DeliverySlip.new(params[:delivery_slip])
    partner = Partner.find( params[:partner][:id] )
    @delivery_slip.address_id = partner.shipping_address_id
    if @delivery_slip.save
      flash[:notice] = 'Bon de livraison créé'
    else
      flash[:notice] = 'Echec de la création du bon de livraison'
    end
    redirect_to :action => 'list'
  end

  def list
    @delivery_slips = DeliverySlip.find :all, :order => 'id DESC'
  end

  # sorties:
  # - liste de q_items
  # - la view se débrouille pour calculer/afficher ce qui a été livré ou pas
  def show
    @dslip = DeliverySlip.find(params[:id])
    @customer = @dslip.address.partner
    @quotation = @dslip.order.quotation
    @items = @dslip.items
    @address = @dslip.address
    @order = @dslip.order
    if @order
      @order_num = @order.order_num
      @order_date = @order.order_date
    end
    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )
    @dest_name = @address.partner.name
  end

  def edit
    @dslip = DeliverySlip.find(params[:id])
    @quotation = @dslip.order.quotation
    @items = @dslip.items
  end

  def update
    @dslip = DeliverySlip.find(params[:id])
    @ds_items = DsItem.find :all, :conditions => ['delivery_slip_id = ?', @dslip.id]
    location = Location.find :first

    DeliverySlip.transaction do
      @ds_items.each do |ds_item|
        old_qty = ds_item.qty.to_i
        new_qty = params[:items][ds_item.id.to_s].to_i
        ds_item.update_attribute( :qty, new_qty )
        # mise à jour des stocks produit
        product = ds_item.q_item.product
        delta = (old_qty - new_qty)
        Stock.update_qty( location.id, product.id, delta )
      end
      @dslip.update_attributes(params[:dslip])
    end

    redirect_to :action => 'edit', :id => @dslip.id
  end


  def destroy_item
    item = DsItem.find(params[:id])
    delivery_slip_id = item.delivery_slip_id
    item.destroy
    redirect_to :action => 'edit', :id => delivery_slip_id
  end

private

  def populate_dsitems( dslip )
    quotation = dslip.order.quotation
    q_items = QItem.find :all,
		:conditions => ["quotation_id = ? and product_id IS NOT NULL", quotation.id]
    for item in q_items
      ordered = item.qty
      delivered_todate = dslip.delivered_todate( item.id )
      undelivered = ordered - delivered_todate
      deliverable = Stock.deliverable(item.product_id)
      if ((undelivered > 0) && (deliverable > 0)) then
        ds_item = DsItem.new
        ds_item.delivery_slip_id = dslip.id
        ds_item.q_item_id = item.id
        ds_item.qty = [undelivered,deliverable].min
        ds_item.save!
      end
    end
  end

  # Met à jour les stocks
  def update_stock( dslip )
    items = DsItem.find :all,
	:conditions => ["delivery_slip_id = ?", dslip.id]
	# FIXME: pas de choix de l'entrepot
	location = Location.find :first, :order => 'name'

    Stock.transaction do
      for item in items
        product = item.q_item.product
        delta = -item.qty
        Stock.update_qty( location.id, product.id, delta )
      end
    end
  end

end
