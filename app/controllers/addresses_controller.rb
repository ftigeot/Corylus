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
