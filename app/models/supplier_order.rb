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

class SupplierOrder < ActiveRecord::Base
  belongs_to	:supplier
  has_many	:so_items, :order => 'so_items.position'
  has_many	:receptions, :order => 'id'

  def total_ht
    subtotal = ActiveRecord::Base.connection.select_values("
		select sum( qty * price ) from so_items
		where supplier_order_id = #{id.to_s}
    ")
    subtotal = subtotal[0].to_f
    subtotal += shipping unless shipping.nil?
    return subtotal
  end

  def vat_rate
    return self.supplier.vat
  end

  def tva
    # country_id 2 is France.
    if (self.supplier.country_id != 2)
      return 0
    else
      tmp = total_ht * vat_rate
      return tmp.round / 100.0
    end
  end

  def total_ttc
    return total_ht + tva
  end

  def official_id
    month = created_on.strftime("%Y%m")
  
    # 1. trouver les id de bon de commande du mois
    orders_of_month = ActiveRecord::Base.connection.select_values("
		select id from supplier_orders
		where to_char(created_on, 'YYYYMM') = '#{month}'
		order by id
    ");
  
    # 2. trouver la position de l'id de du bon de commande en cours dans
    # cette liste d'id
    # le +1 c'est parce qu'on commence à compter à partir de 1
    id_pos = orders_of_month.index( id.to_s ) + 1
  
    return month + '-' + id_pos.to_s
  end

  def supplier_name
    name = ActiveRecord::Base.connection.select_value("
	select name from partners
	where id = #{self.supplier_id}
    ");
    return name
  end

  def fully_received?
    so_items = SoItem.find :all,
    	:conditions => ['supplier_order_id = ? and product_id IS NOT NULL', self.id]
    reception_list = Reception.find :all,
    	:conditions => ['supplier_order_id = ?', self.id]
    for item in so_items
      ordered = item.qty
      received = ReceptionItem.sum :qty,
		:conditions => ['product_id = ? and reception_id in (?)', item.product_id, reception_list]
      received = 0 if (received.nil?)
      not_received = ordered - received
      return false if (not_received > 0)
    end
    return true
  end

  def shipping_address
    return Address.find( self.shipping_address_id )
  end

  # Retourne la quantité d'un type de produits réceptionné à l'heure actuelle
  def delivered_todate( product_id, reception_id )
    ActiveRecord::Base.connection.select_value("
		select sum(qty) from reception_items
		where reception_id in (
			select id from receptions
			where id <= #{reception_id}
			and supplier_order_id = #{id}
		)
		and product_id = #{product_id}
    ").to_i
  end

end
