# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Supplier < Partner

  def self.find(*args)
    options = args.extract_options!
    options[:conditions] ||= 'is_supplier = true'
    super(*args.push(options))
  end

  def primary_address
    return billing_address
  end

end
