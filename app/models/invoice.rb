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

class Invoice < ActiveRecord::Base
  belongs_to :order
  belongs_to :address
  belongs_to :delivery_slip, :foreign_key => 'ds_id'

  before_create :create_public_id

  # Retourne un tableau contenant les taux de tva des différents
  # produits et la somme totale de la tva associée à chaque taux.
  # Attention: on doit prendre les infos de tva dans les devis, les taux
  # de tva peuvent avoir changé depuis la création des documents
  def vat_rates

    # Facture sur la totalité de la livraison
    quotation = Quotation.find( self.order.quotation_id )
    return quotation.vat_rates( self.shipping ) if (self.delivery_slip.nil?)

    # Facture sur livraison partielle ?

    # 1. On récupère la liste des lignes produit livrées
    ds_items = DsItem.find :all,
    	:conditions => ['delivery_slip_id = ?', self.ds_id]
    dsi_list = ds_items.map{ |i| ActiveRecord::Base.connection.quote(i) }.join(',')

    # 2. On récupère les différents taux de tva des produits
    rates = ActiveRecord::Base.connection.select_values("
		select distinct vat
		from q_items qi, ds_items dsi
		where qi.id = dsi.q_item_id
		and dsi.id in (#{dsi_list})
    ")

    # 3. Ajout des frais de port
    str = quotation.shipping_tr
    tmp_shipping = shipping.nil? ? 0 : shipping
    if ((tmp_shipping > 0) && !rates.include?(str.to_s))
      rates.push str
    end

    vat_rates = []
    for r in rates
      vr = VatRate.new
      vr.rate = r.to_f
      vr.value = ActiveRecord::Base.connection.select_value("
      	select sum(qi.price * dsi.qty * qi.vat)
		from q_items qi, ds_items dsi
		where qi.id = dsi.q_item_id
		and dsi.id in (#{dsi_list})
		and vat = #{vr.rate}
      ").to_f
      vr.value += tmp_shipping * str if (vr.rate == str)
      vr.value = vr.value.round / 100.0
      vat_rates << vr
    end
    return vat_rates
  end

  def total_ht
    return ActiveRecord::Base.connection.select_value("
    	select iv_sum(#{self.id})"
    ).to_f;
  end

  def tva
    return ActiveRecord::Base.connection.select_value("
    	select iv_vat(#{self.id})"
    ).to_f;
  end

  def total_ttc
    return total_ht + tva
  end

private

  def create_public_id
    year = Date.today.year.to_s

    # 1. get the number of all invoices for this year
    invoices_of_year = ActiveRecord::Base.connection.select_value("
		select count(*) from invoices
		where to_char(created_on, 'YYYY') = '#{year}'
    ");

    # 2. counting starts from 1, so we add 1 to the result
    newid = invoices_of_year.to_i + 1

    self.public_id = year + '-' + newid.to_s
  end

end
