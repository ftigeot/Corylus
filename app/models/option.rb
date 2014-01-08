# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Option < ActiveRecord::Base
  has_many	:product_lines
  has_many	:products, :through => :product_lines
  has_many	:option_values, :order => 'option_values.position'

  def default_value
    ActiveRecord::Base.connection.select_value("
		select ov.id from options o, option_values ov
		where ov.option_id = o.id
		and ov.default_value = true
		and o.id = #{id}
    ").to_i
  end

end
