# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

  def fmt_price( amt )
    if amt.nil?
      sprintf("NC")
    else
      sprintf("%.2f €", amt)
    end
  end

end
