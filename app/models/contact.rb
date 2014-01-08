# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot
class Contact < ActiveRecord::Base
  belongs_to	:customer
  belongs_to	:supplier
end
