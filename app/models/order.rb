# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Order < ActiveRecord::Base
  belongs_to :quotation
  has_many :invoices, :order => 'id'
  has_many :delivery_slips

  # Détermine si toute la commande a été livrée
  # Cette fonction se base sur la présence de bons de livraison
  def fully_delivered?
    q_items = QItem.find :all,
    	:conditions => ["quotation_id = ? and product_id IS NOT NULL", self.quotation.id]
    for item in q_items
      ordered = item.qty
      delivered = ActiveRecord::Base.connection.select_value("
		select sum(qty) from ds_items
		where q_item_id = #{item.id}
      ").to_i
      undelivered = ordered - delivered
      return false if (undelivered > 0)
    end
    return true
  end

  def fully_charged?
    # 1. facture globale ?
    invoice = Invoice.find :first,
	  :conditions => ['order_id = ? and ds_id IS NULL', self.id]
    return true unless invoice.nil?

    # 2. plusieurs factures:
    invoices = self.invoices
    q_items = QItem.find :all, :conditions => ["
		quotation_id = ? and qty >= 1
		and product_id IS NOT NULL", self.quotation.id]
    for item in q_items
      ordered = item.qty
      charged = ActiveRecord::Base.connection.select_value("
		select sum(qty) from ds_items
		where delivery_slip_id in (
		  select ds_id from invoices
		  where invoices.order_id = #{self.id}
		)
		and ds_items.q_item_id = #{item.id}
      ").to_i
      next if (charged == ordered)

      # 3. Tout n'a pas été facturé, on vérifie si il y a des abandons
      cancelled = ActiveRecord::Base.connection.select_value("
	    SELECT SUM(qty) FROM ds_items dsi, delivery_slips ds
		WHERE dsi.q_item_id = #{item.id}
		AND dsi.delivery_slip_id = ds.id
		AND ds.cancelled = TRUE
      ").to_i

      uncharged = ordered - charged - cancelled
      return false if (uncharged > 0)
    end
    return true
  end

  # undelivered(): retourne une liste de Items non livrés
  def undelivered
    q_items = QItem.find :all,
    	:conditions => ["quotation_id = ? and product_id IS NOT NULL", self.quotation.id]
    undelivered_items = []
    for qi in q_items
      ordered = qi.qty
      delivered = ActiveRecord::Base.connection.select_value("
		select sum(qty) from ds_items
		where q_item_id = #{qi.id}
      ").to_i
      undelivered = ordered - delivered
      if (undelivered > 0)
        item = Item.new
        item.description = qi.description
        item.product_id  = qi.product_id
        item.undelivered = undelivered
        undelivered_items << item
      end
    end
    undelivered_items
  end

end
