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

class ReceptionsController < ApplicationController

  def list
    @receptions = Reception.paginate :page => params[:page],
    	:per_page => 50, :order => 'created_on DESC,id DESC'
  end

  def show
    @reception = Reception.find(params[:id])
  end

  def new
    @supplier_order = SupplierOrder.find( params[:id] )
    @reception = Reception.new
    @reception.supplier_id = @supplier_order.supplier_id
    @reception.supplier_order_id = @supplier_order.id
    @locations = Location.find :all, :order => 'name'
  end

  def create
    @reception = Reception.new( params[:reception] )
  # TODO: vérifier que tout livré ou pas.
  # Si tout livré, refuser de créer à nouveau un bon de réception.
    Reception.transaction do
      @reception.save!
      populate_reception( @reception )
    end
    redirect_to :action => 'edit', :id => @reception.id
  end

  def edit
    @reception = Reception.find(params[:id])
    @fournisseurs = Supplier.find :all, :order => 'name'
    @locations = Location.find :all, :order => 'name'
    @categories = Category.find :all, :order => 'name',
    	:conditions => ["parent_id is NULL"]
  end

  def new_line
    @reception = Reception.find(params[:id])
    @product = Product.find(params[:product][:id])
    reception_item = ReceptionItem.new
    reception_item.reception_id = @reception.id
    reception_item.qty = 0
    reception_item.product_id = @product.id
    unless reception_item.save
      flash[:notice] = "Echec de l'ajout d'une nouvelle ligne"
    end
    redirect_to :action => 'edit', :id => @reception.id
  end

  def empty_line
    @reception = Reception.find(params[:id])
    reception_item = ReceptionItem.new
    reception_item.reception_id = @reception.id
    reception_item.qty = 1
    unless reception_item.save
      flash[:notice] = "Echec de l'ajout d'une nouvelle ligne vide"
    end
    redirect_to :action => 'edit', :id => @reception.id
  end

  def update
    @reception = Reception.find(params[:id])
    @reception_items = ReceptionItem.find :all, :conditions => ['reception_id = ?', params[:id]]
    Reception.transaction do
      @reception_items.each do |reception_item|
        old_qty = reception_item.qty.to_i
        new_qty = params[:reception_item][reception_item.id.to_s][:qty].to_i
        os = reception_item.status
        ns = params[:reception_item][reception_item.id.to_s][:status]
        reception_item.update_attributes( params[:reception_item][reception_item.id.to_s] )

        # mise à jour des stocks produit
        # une livraison annulée n'enlève pas des produits du stock
        product = reception_item.product
        delta = (new_qty - old_qty) if (os == 'ok' && ns == 'ok')
        delta = -new_qty if (os == 'ok' && ns == 'canceled')
        delta =  new_qty if (os == 'canceled' && ns == 'ok')
        delta = 0 if (os == 'canceled' && ns == 'canceled')

        Stock.update_qty( @reception.location_id, product.id, delta )
      end
      if @reception.update_attributes(params[:reception])
        flash[:notice] = 'Reception was successfully updated.'
      end
    end # transaction
    redirect_to :action => 'edit', :id => @reception.id
  end

  def destroy_item
    item = ReceptionItem.find(params[:id])
    if (item.status == 'ok')
      delta = -item.qty
      Reception.transaction do
        Stock.update_qty( item.reception.location_id, item.product_id, delta )
        item.destroy
      end
    end
    redirect_to :action => 'edit', :id => item.reception.id
  end

  def browse_next_ajax
    @cat = Category.find(params[:id])
    @cats = @cat.children if @cat
    if (@cats && @cats.size > 0)
      render :partial => 'select_category', :layout => false
    else
      @products = Product.find( :all, :conditions => ["category_id = ?", @cat.id],
		:order => 'name' )
      render :partial => 'select_product', :layout => false
    end
  end

  def ajax_select_product
    @product = Product.find(params[:id])
    @reception_item = ReceptionItem.find(197)
    render :partial => 'product_selected', :layout => false
  end

private

  # Crée les lignes reception_items correspondant à une réception de
  # produit
  def populate_reception( reception )
    order = reception.supplier_order
    # 1. Parcours du bon de commande initial
    for item in order.so_items
      next if (item.product_id.nil?)
      ordered = item.qty
      delivered_todate = order.delivered_todate( item.product_id, reception.id )
      undelivered = ordered - delivered_todate
      if (undelivered > 0) then
        # FIXME: pas besoin d'avoir prix, description
        ri = ReceptionItem.new
        ri.reception_id = reception.id
        ri.product_id = item.product_id
        ri.description = item.description
        ri.qty = undelivered
        ri.status = 'ok'
        reception.reception_items << ri
        Stock.update_qty( reception.location_id, ri.product_id, ri.qty )
      end # undelivered > 0
    end
  end

end
