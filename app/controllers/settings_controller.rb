# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class SettingsController < ApplicationController

  def show
    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )
    @shipping_address = Address.find( Setting.shipping_address_id )
    @billing_bic  = Setting.bic
    @billing_iban = Setting.iban
  end

  def edit
    @settings = Setting.find :first
  end

  def update
    @settings = params[:settings]
    @company_name = @settings['company_name']
    Setting.company_name = @company_name
    Setting.bic = @settings['bic']
    Setting.iban = @settings['iban']
    redirect_to :action => 'show'
  end

end
