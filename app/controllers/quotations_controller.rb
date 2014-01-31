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

# Gestion de la création et l'affichage des devis

class QuotationsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  def list
    @quotations = Quotation.paginate :page => params[:page],
	:per_page => 33, :order => 'id DESC'
  end

  def show
    @quotation = Quotation.find(params[:id])
    @q_items = @quotation.q_items
    @is_editable = (@quotation.order == nil)
    @total_ht = @quotation.total_ht
    @shipping = @quotation.shipping
    @vat_rates = @quotation.vat_rates
    @total_ttc = @quotation.total_ttc
    h = request.host
    filename = Setting.company_name + "_devis_" + @quotation.id.to_s + ".pdf"
    @pdf_url = URI.parse(TOMCAT_BASE +
	"Devis.pdf?host=#{h}&id=#{@quotation.id}&filename=#{filename}").to_s
  # Required for XML views
    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )
    @address = @quotation.customer.billing_address
  end

  def edit
    @quotation = Quotation.find(params[:id])
    @customers = Customer.find( :all, :order => 'name' )
    @q_items = @quotation.q_items
  end

  def new_line
    @quotation = Quotation.find(params[:id])
    q_item = QItem.new
    q_item.quotation_id = @quotation.id
    q_item.description = ''
    unless q_item.save
      flash[:notice] = "Echec de l'ajout d'une nouvelle ligne"
    end
    redirect_to :action => 'edit', :id => @quotation.id
  end

  def update
    @quotation = Quotation.find(params[:id])
    @q_items = QItem.find :all, :conditions => ['quotation_id = ?', params[:id]]
    @q_items.each do |q_item|
      q_item.update_attributes( params[:q_item]["#{q_item.id}"] )
    end
    if @quotation.update_attributes(params[:quotation])
      flash[:notice] = 'Quotation was successfully updated.'
    end
    redirect_to :action => 'edit', :id => @quotation.id
  end

  def destroy_item
    q_item = QItem.find(params[:id])
    quotation_id = q_item.quotation_id
    q_item.destroy
    redirect_to :action => 'edit', :id => quotation_id
  end

  # demande un devis pdf à un servlet tomcat et retourne le résultat
  def devis_pdf
    @quotation = Quotation.find(params[:id])
    require 'net/http'
    @host = request.host
    tomcat_url = URI.parse( TOMCAT_BASE + "Devis.pdf?host=#{@host}&id=#{@quotation.id}")
    pdf = Net::HTTP.get(tomcat_url)
    filename = Setting.company_name + "_devis_" + @quotation.id.to_s + ".pdf"
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    render :text => pdf, :content_type => 'application/pdf'
  end

  def duplicate
    @quotation = Quotation.find(params[:id])
    @q_items = QItem.find :all, :conditions => ['quotation_id = ?', @quotation.id],
		:order => 'position'
    q2 = @quotation.dup
    q2.created_on = Date.today
    q2.updated_on = Date.today
    for qi in @q_items do
      q2.q_items << qi.dup
    end
    q2.save!
    redirect_to :controller => 'quotations', :action => 'list'
  end

end
