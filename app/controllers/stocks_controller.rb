# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class StocksController < ApplicationController

  def list
    @stocks = Stock.find_by_sql ["
      SELECT DISTINCT stocks.*,products.category_id,products.position
      FROM stocks
      INNER JOIN products ON products.id = stocks.product_id
      ORDER BY products.category_id, products.position"]

    @locations = Location.find :all, :order => 'name'
  end

end
