# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Partner < ActiveRecord::Base
  has_many :events,   :order => 'created_on'
  has_many :contacts, :order => 'lastname,firstname'
  has_many :addresses
  belongs_to :country

  before_save :strip_empty_strings

  def billing_address
    baid = billing_address_id
    return Address.find( baid )
  end

  def shipping_address
    said = shipping_address_id
    return Address.find( said )
  end


private

  def strip_empty_strings
    self.long_name = nil if (self.long_name == '')
  end

end
