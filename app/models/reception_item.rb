# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ReceptionItem < ActiveRecord::Base
  belongs_to :reception
  belongs_to :product
end
