# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot
class Category < ActiveRecord::Base
  acts_as_tree	:order => 'name'
  has_many	:products

  def valid_products
    return Product.find( :all,
	:conditions => ['category_id = ? and obsolete = false', self.id] )
  end

end
