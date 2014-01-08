# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Customer < Partner

  def self.find(*args)
    options = args.extract_options!
    options[:conditions] ||= 'is_customer = true'
    super(*args.push(options))
  end

end
