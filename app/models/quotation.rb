# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

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

    vat_rates = []
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
