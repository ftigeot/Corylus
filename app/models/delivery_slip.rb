# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class DeliverySlip < ActiveRecord::Base
  belongs_to :order
  has_many :ds_items
  belongs_to :address

  def official_id
    month = created_on.strftime("%Y%m")

    # numéro de fin:
    # 1. trouver les id des bons de livraison du mois
    dslips_of_month = ActiveRecord::Base.connection.select_values("
		select id
		from delivery_slips
		where to_char(created_on, 'YYYYMM') = '#{month}'
		order by id
    ");

    # 2. trouver la position du bon de livraison en cours dans cette
    # liste d'id
    # le +1 c'est parce qu'on commence à compter à partir de 1
    id_pos = dslips_of_month.index( id.to_s ) + 1

    return month + '-' + id_pos.to_s
  end

  # Can we emit an invoice for a specific delivery slip ?
  def invoice_possible?
    # 1. facture globale ?
    invoices = Invoice.find :first,
    	:conditions => ['order_id = ? AND ds_id IS NULL', self.order_id]
    return false if (!invoices.nil?)
    # 2. facture pour cette livraison ?
    invoices = Invoice.find :first, :conditions => ['ds_id = ?', self.id]
    return false if (!invoices.nil?)
    # 3. bon de commande pour cette livraison ?
    return false if (self.order_id.nil?)
    return true
  end

  # liste des produits livrés
  # sortie: liste des lignes correspondant à un produit, classées par la
  # position correspondante dans le devis
  # les produits non livrés ont quand-même une ligne, mais avec delivered = 0
  # 
  # Les items retournés sont une construction de plus haut niveau que les
  # lignes de la table ds_item
  def items
    q_id = order.quotation.id
    q_items = QItem.find :all,
		:conditions => ["quotation_id = ? and product_id is not null", q_id],
		:order => 'q_items.position'

    items = []
    for qi in q_items
      ordered = qi.qty
      delivered = ActiveRecord::Base.connection.select_value("
        select qty from ds_items
        where delivery_slip_id = #{self.id}
        and q_item_id = #{qi.id}
      ").to_i
      delivered_todate = delivered_todate( qi.id )
      item = Item.new
      ds_item = DsItem.find :first,
		:conditions => ['delivery_slip_id = ? and q_item_id = ?', id, qi.id]
      if (ds_item.nil?)
        item.dsi_id = nil
      else
        item.dsi_id = ds_item.id
      end
      item.description = qi.description
      item.ordered = ordered
      item.delivered = delivered
      item.delivered_todate = delivered_todate
      items << item
    end
    items
  end

  # Retourne le nombre de produits livré à l'heure actuelle
  # par ligne de devis pour les bons de livraison partiels
  def delivered_todate( qitem_id )
    ActiveRecord::Base.connection.select_value("
		select sum(qty) from ds_items
		where delivery_slip_id in (
			select id from delivery_slips
			where order_id = #{order_id}
		)
		and q_item_id = #{qitem_id}
    ").to_i
  end

  def pdf_url
    h = $request_host
    filename = Setting.company_name + "_bon_de_livraison_" + self.id.to_s + ".pdf"
    return URI.parse(AppConfig.tomcat_base +
	"BonLivraison.pdf?host=#{h}&id=#{self.id}&filename=#{filename}").to_s
  end

end
