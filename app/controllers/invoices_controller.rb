# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class InvoicesController < ApplicationController

  def new
    @order = Order.find(params[:id])
    new_common
  end

  def new_partial
    @delivery_slip = DeliverySlip.find(params[:id])
    @order = @delivery_slip.order
    new_common
    @invoice.ds_id = @delivery_slip.id
    render :action => 'new'
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    if @invoice.save
      redirect_to :action => 'show', :id => @invoice.id
    else
      render :action => 'new'
    end
  end

  # Il est à noter que l'on récupère les lignes de commentaire
  # (dont le product_id est NULL) pour les afficher
  def show
    @invoice = Invoice.find(params[:id])
    @order = @invoice.order
    @quotation = @order.quotation
    ds_id = @invoice.ds_id

    # Facture unique ?
    if (ds_id.nil?)
      # oui => récupère toutes les lignes du devis
      @q_items = QItem.find :all,
      	:conditions => [ 'quotation_id = ?', @quotation.id ], :order => 'position'
    else
      # non => ne récupère que les lignes de cette livraison
      @q_items = QItem.find :all, :conditions => ['
      	quotation_id = ?
      	AND id IN (
      		SELECT q_item_id
      		FROM ds_items
      		WHERE delivery_slip_id = ?
      )', @quotation.id, ds_id ], :order => 'position'
      # et met à jour les quantités de produit
      for item in @q_items
        next if (item.product_id.nil?)
        dsi = DsItem.find :first, :conditions => ['
        	q_item_id = ? and delivery_slip_id = ?', item.id, ds_id]
        index = @q_items.index(item)
        @q_items[index].qty = dsi.qty
      end
    end

    @address = @invoice.address
    @total_ht = @invoice.total_ht
    @shipping = @invoice.shipping
    @vat_rates = @invoice.vat_rates
    @total_ttc = @invoice.total_ttc
    h = request.host
    filename = Setting.company_name + "_facture_" + @invoice.public_id.to_s + ".pdf"
    @pdf_url = URI.parse(TOMCAT_BASE +
	"Facture.pdf?host=#{h}&id=#{@invoice.id}&filename=#{filename}").to_s
  end

  def facture
    show
    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )
    @billing_bic = Setting.bic
    @billing_iban = Setting.iban
    if @invoice.delivery_slip
      @delivery_address = @invoice.delivery_slip.address
    else
      @delivery_address = nil
    end
    render :layout => false
  end

  # Get a pdf document from a tomcat server
  def facture_pdf
    @invoice = Invoice.find(params[:id])
    require 'net/http'
    @host = request.host
    tomcat_url = URI.parse( TOMCAT_BASE + "Facture.pdf?host=#{@host}&id=#{@invoice.id}.xml")
    pdf = Net::HTTP.get(tomcat_url)
    response.headers['Content-Disposition'] =
    		"attachment; filename=\"Facture #{@invoice.public_id}.pdf\""
    render :text => pdf, :content_type => 'application/pdf'
  end

  def envelope
    show
    @address = @quotation.customer.billing_address
    if (@address.service.nil? or @address.service == '')
      @service_compta = 'Service comptabilité'
    else
      @service_compta = @address.service
    end
    render :layout => false
  end

  def list
    @invoices = Invoice.paginate :page => params[:page],
    	:per_page => 31, :order => 'id DESC'
  end

  def list_unpaid
    @invoices = Invoice.paginate :page => params[:page],
    	:conditions => 'paiement_date IS NULL and is_credit_note = false', :order => 'id DESC'
    @unpaid_sum = 0
    for invoice in @invoices
      @unpaid_sum += invoice.total_ht
    end
    render :action => 'list'
  end

  def pay
    @invoice = Invoice.find(params[:id])
    @quotation = @invoice.order.quotation
  end

  def paid
    @invoice = Invoice.find(params[:id])
    unless @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Erreur de mise à jour de la date de paiement.'
    end
    redirect_to :action => 'show', :id => @invoice.id
  end

  def list_by_duedate
    @invoices = Invoice.find :all, :conditions => 'due_date IS NOT NULL', :order => 'due_date ASC'
    render :action => 'list'
  end

  def export_compta
    @invoices = Invoice.find :all, :conditions => ['created_on = ?', '2008-07-18']
    render :layout => false
  end

  def list_compta
    @invoices = Invoice.paginate :page => params[:page],
	:per_page => 31, :order => 'id DESC'
  end

private

  def new_common
    quotation = @order.quotation
    customer = quotation.customer

    @invoice = Invoice.new
    @invoice.order_id = @order.id
    @invoice.due_date = nil
    @invoice.address = customer.billing_address
    # paiement à crédit ?
    if customer.payment_delay
      @invoice.due_date = Date.today + customer.payment_delay
    end
    @invoice.shipping = quotation.shipping
  end

end
