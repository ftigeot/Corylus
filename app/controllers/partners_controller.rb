# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class PartnersController < ApplicationController

  def list
    @partners = Partner.find :all, :order => 'name'
  end

  def show
    @partner = Partner.find(params[:id])
    @events = @partner.events
    @contacts = @partner.contacts
  end

  def new
    @partner = Partner.new
    @address = Address.new
  end

  def create
    @partner = Partner.new(params[:partner])
    @address = Address.new(params[:address])

    Partner.transaction do
      render :action => 'new' unless @partner.save
      @address.partner_id = @partner.id
      if @address.save
        flash[:notice] = 'Partner was successfully created.'
      else
        flash[:notice] = 'Partner was created but the associated adress wasn''t.'
      end
      @address = Address.find :first, :conditions => ['partner_id = ?', @partner.id]
      @partner.shipping_address_id = @address.id
      @partner.billing_address_id = @address.id
      @partner.save!
    end
    redirect_to :action => 'list'
  end

  def show_invoices
    @partner = Customer.find(params[:id])
    @invoices = Invoice.find_by_sql ['
	select i.*
	from invoices i, orders o, quotations q
	where i.order_id = o.id
	and o.quotation_id = q.id
	and q.customer_id = ?
	order by i.id DESC', @partner.id ]
  end

  def show_orders
    @partner = Supplier.find(params[:id])
    @orders = SupplierOrder.find_by_sql ['
	select o.*
	from supplier_orders o
	where o.supplier_id = ?
	order by o.id DESC', @partner.id ]
  end

  def list_unpaid
    @partner = Partner.find(params[:id])
    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )
    @p_address = @partner.billing_address
    @today = Date.today

    # 1. On part de la liste des factures non payées par le client
    @invoices = Invoice.find_by_sql ['
	select i.*
	from invoices i, orders o, quotations q
	where i.order_id = o.id
	and o.quotation_id = q.id
	and q.customer_id = ?
	AND i.is_credit_note = false
	AND i.paiement_date IS NULL
	order by i.id DESC', @partner.id ]

    for invoice in @invoices
      if (invoice.due_date.nil?)
        # 2. date de paiement à réception de facture ?
        # => On laisse 2 jours depuis la date de la facture
        date_limite = invoice.created_on + 2
      else
        date_limite = invoice.due_date
      end

      # 3. date limite non atteinte ?
      # => on ne prend pas en compte cette facture
      if ((date_limite <=> @today) == 1)
        @invoices.delete(invoice)
      end
    end

    # 4. Calcul de la somme totale restant due
    @unpaid_sum = 0
    for invoice in @invoices
      @unpaid_sum += invoice.total_ttc
    end

    respond_to do |format|
      format.html
      format.xml
      format.pdf { get_pdf }
    end
  end

  def new_event
    @partner = Partner.find(params[:id])
    @event = Event.new
    @event.partner_id = @partner.id
  end

  def create_event
    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = 'Event succesfully created'
      redirect_to :action => 'show', :id => @event.partner_id
    else
      render :action => 'new_event'
    end
  end

  def edit_event
    @event = Event.find(params[:id])
  end

  def edit
    @partner = Partner.find(params[:id])
  end

  def update
    @partner = Partner.find(params[:id])
    if @partner.update_attributes(params[:partner])
      flash[:notice] = 'Partner record updated.'
      redirect_to :action => 'show', :id => @partner
    else
      render :action => 'edit'
    end
  end

  def update_event
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully edited.'
      redirect_to :action => 'show', :id => @event.partner_id
    else
      render :action => 'edit_event'
    end
  end

  def destroy
    partner = Partner.find( params[:id] )
    addresses = partner.addresses
    contacts = partner.contacts
    events = partner.events

    Partner.transaction do
      partner.billing_address_id = nil
      partner.shipping_address_id = nil
      partner.save!
      addresses.each {|address| address.destroy }
      contacts.each {|contact| contact.destroy }
      events.each {|event| event.destroy }
      partner.destroy
    end

    flash[:notice] = 'Partner ' + partner.name + ' was successfully deleted.'
    redirect_to :action => 'list'
  end

private

  # Get a pdf document from a tomcat server
  def get_pdf
    require 'net/http'
    src_url = url_for :controller => 'partners',
		:action => 'list_unpaid', :id => @partner.id,
		:protocol => 'http', :format => 'xml'
    tomcat_url = URI.parse( TOMCAT_BASE + "FopPDF?src=#{src_url}&xsl=statement.xsl")
    pdf = Net::HTTP.get(tomcat_url)
    render :text => pdf, :content_type => 'application/pdf'
  end

end
