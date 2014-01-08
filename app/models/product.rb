# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Product < ActiveRecord::Base
  belongs_to :category
  validates_associated :category
  validates_uniqueness_of :name
  validates_numericality_of :public_price

  has_many :product_suppliers, :order => 'updated_on DESC'
  has_many :suppliers, :through => :product_suppliers

  has_many :components, :foreign_key => 'owner_id', :order => 'position'
  has_many :product_lines, :order => 'position'
  has_many :options, :through => :product_lines,
  	:select => 'product_lines.position, options.*',
  	:order => 'product_lines.position'
  belongs_to :vat_rate
  acts_as_list	:scope => :category

  # Return a list of products
  SEARCHABLE_FIELDS = "name,description,specs,comment"
  def self.search( text )
    return nil if (text.nil?)
    t = '%' + text.downcase + '%'
    conditions = '
	lower(name) LIKE ?
	or lower(description) LIKE ?
	or lower(specs) LIKE ?
	or lower(comment) LIKE ?'
    return Product.find( :all, :conditions => [conditions, t, t, t, t] )
  end

  def components_cost
    cost = 0.00
    self.components.each { |c| cost += c.qty * c.product.public_price }
    return cost
  end

  def related_products
    # 1. Find the set of relationships this product belongs to
    relation_list = ActiveRecord::Base.connection.select_values("
		select relation_id from related_products
		where product_id = #{id}
    ")
    return nil if (relation_list.empty?)

    # 2. Find the list of product_ids belonging to this relation
    product_list = ActiveRecord::Base.connection.select_values("
		select product_id from related_products
		where relation_id in (#{relation_list})
		and product_id <> #{id}
    ")
    return nil if (product_list.empty?)

    # 3. Retourne les objets produit correspondants
    return Product.find( :all, :conditions => ['id in (?)', product_list])
  end

  def stock
    stock = Stock.sum 'qty', :conditions => ["product_id = ?", id]
    return (stock.nil? ? 0 : stock)
  end

  def vat
    return vat_rate.rate
  end

protected

  # Les produits composés peuvent avoir un prix de base à 0.
  def validate
    errors.add( :public_price, "should be zero or positive") unless public_price.nil? || public_price >= 0.00
  end

end
