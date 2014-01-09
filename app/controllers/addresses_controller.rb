# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class AddressesController < ApplicationController

  def new
    @address = Address.new
    @partner = Partner.find(params[:id])
    @address.partner_id = @partner.id
    @name = @partner.name
  end

  def create
    @address = Address.new(params[:address])
    if @address.save
      partner = @address.partner 
      if (partner.billing_address.nil?)
        partner.billing_address_id = @address.id
        partner.update
      end
      redirect_to :action => 'list', :id => @address.partner_id
    else
      render :action => 'new'
    end
  end

  def edit
    @address = Address.find(params[:id])
  end

  def show
    @address = Address.find(params[:id])
  end

  def update
    @address = Address.find(params[:id])
    if @address.update_attributes(params[:address])
      flash[:notice] = 'Address successfully updated.'
      redirect_to :action => 'list', :id => @address.partner_id
    else
      render :action => 'edit'
    end
  end

  def list
    @host = request.host
    if (params[:id].nil?)
      @name = Setting.company_name
      @addresses = Address.find :all, :conditions => ['partner_id IS NULL']
      @billing_address = Address.find( Setting.billing_address_id )
      @shipping_address = Address.find( Setting.shipping_address_id )
    else
      @company = Partner.find(params[:id])
      @name = @company.name
      @addresses = @company.addresses
      @billing_address = @company.billing_address
      @shipping_address = @company.shipping_address
    end
  end

  def set_shipping
    @address = Address.find(params[:id])
    if @address.partner_id.nil?
      Setting.shipping_address_id = @address.id
    else
      @partner = @address.partner
      @partner.shipping_address_id = @address.id
      @addresses = @partner.addresses
      @partner.save!
    end
    redirect_to :action => 'list', :id => @address.partner_id
  end

  def set_billing
    @address = Address.find(params[:id])
    if @address.partner_id.nil?
      Setting.billing_address_id = @address.id
    else
      @partner = @address.partner
      @partner.billing_address_id = @address.id
      @addresses = @partner.addresses
      @partner.save!
    end
    redirect_to :action => 'list', :id => @address.partner_id
  end

  def envelope
    @orig = Address.find(Setting.billing_address_id)
    @address = Address.find(params[:id])
    if (@address.service.nil? or @address.service == '')
      @service = 'Service comptabilité'
    else
      @service = @address.service
    end
    render :layout => false
  end

end
