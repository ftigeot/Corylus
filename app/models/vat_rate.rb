# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

# This class exists to manage different VAT rates
class VatRate < ActiveRecord::Base
  attr_accessor	:value
end
