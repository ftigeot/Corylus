# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class OrdersController < ApplicationController

  def new
    @quotation = Quotation.find(params[:id])
    @order = Order.new
    @order.quotation_id = @quotation.id
    @order.order_date = @quotation.created_on
  end

  def create
    @order = Order.new(params[:order])
    # Le champ order_num a une taille maximum de 16 caractères.
    @order.order_num = @order.order_num.slice(0..15)
    @order.order_num = nil if @order.order_num == ''
    if @order.save
      redirect_to :action => 'show', :id => @order.id
    else
      render :action => 'new'
    end
  end

  def list
    @orders = Order.find :all, :order => 'order_date DESC'
  end

  def list_open
    # Optimisation: limite la recherche initiale aux bons de commande
    # sans facture globale
    tmp_orders = Order.find_by_sql '
    	select o.* from orders o
    	where not exists (
    		select i.id from invoices i
    		where i.order_id = o.id
    		and i.ds_id IS NULL
    	)
    	and o.canceled = false
    	order by order_date ASC, o.id'
    @orders = []
    for order in tmp_orders
      @orders << order unless order.fully_charged?
    end
    render :action => 'list'
  end

  def show
    @order = Order.find(params[:id])
    @quotation = @order.quotation
    @q_items = QItem.find :all,
    	:conditions => [ "quotation_id = ?", @quotation.id ], :order => 'position'
    @shipping = @quotation.shipping

    @dslips = DeliverySlip.find :all,
    	:conditions => ["order_id = ?", @order.id], :order => 'id'
    @has_dslip = (@dslips.empty? == false)

    @invoices = @order.invoices
    @fully_delivered = @order.fully_delivered?
    @undelivered_items = @order.undelivered
    @total_ht = @quotation.total_ht
    @vat_rates = @quotation.vat_rates
    @total_ttc = @quotation.total_ttc
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:order][:id])
    if @order.update_attributes(params[:order])
      redirect_to :action => 'show', :id => @order.id
    else
      render :action => 'edit'
    end
  end

end
