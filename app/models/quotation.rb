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

class Quotation < ActiveRecord::Base
  belongs_to :customer
  belongs_to :user
  has_many :q_items, :order => 'q_items.position'
  has_one :order
  validates_presence_of :customer

  def total_ht
    subtotal = ActiveRecord::Base.connection.select_values("
		select sum( qty * price ) from q_items
		where quotation_id = #{id}
    ")
    subtotal  = subtotal[0].to_f
    subtotal += shipping unless shipping.nil?
    return subtotal
  end

  # Retourne un tableau contenant les taux de tva des différents
  # produits et la somme totale de la tva associée à chaque taux.
  def vat_rates( _shipping = self.shipping )
    vat_rates = []

    # No VAT for non-EU countries
    customer_country = self.customer.country_id
    foreign_country = ActiveRecord::Base.connection.select_value("
	select is_foreign_country(#{customer_country})
    ")
    if (foreign_country)
      vr = VatRate.new
      vr.rate = 0
      vr.value = 0.0
      vat_rates << vr
      return vat_rates
    end

    rates = ActiveRecord::Base.connection.select_values("
    	select distinct vat from q_items
    	where quotation_id = #{id}
    	and product_id is not null
    ")
    # Ajout des frais de port
    str = self.shipping_tr
    tmp_shipping = _shipping.nil? ? 0 : _shipping
    if ((tmp_shipping > 0) && !rates.include?(str.to_s))
      rates.push str
    end

    for r in rates
    	vr = VatRate.new
    	vr.rate = r.to_f
    	vr.value = ActiveRecord::Base.connection.select_value("
    		select sum( qty * price * vat ) from q_items
    		where quotation_id = #{id}
    		and product_id is not null
    		and vat = #{vr.rate}
    	").to_f
    	vr.value += tmp_shipping * str if (vr.rate == str)
    	vr.value = vr.value.round / 100.0
    	vat_rates << vr
    end
    return vat_rates
  end

  def tva
    # No VAT for non-EU countries
    customer_country = self.customer.country_id
    foreign_country = ActiveRecord::Base.connection.select_value("
	select is_foreign_country(#{customer_country})
    ")
    return 0 if (foreign_country)

    vat = ActiveRecord::Base.connection.select_value("
    	select sum( qty * price * vat ) from q_items
    	where quotation_id = #{id}
    	and product_id is not null
    ").to_f
    vat += shipping * shipping_tr unless shipping.nil?

    return vat / 100.0
  end

  def total_ttc
    return total_ht + tva
  end

end
