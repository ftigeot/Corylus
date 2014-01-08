# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Address < ActiveRecord::Base
  belongs_to :country
  belongs_to :partner

  def company_name
    if (partner_id.nil?)
      return Setting.company_name
    else
      return partner.name
    end
  end

  def short_name
    tmp_name = company_name + ', ' + city
    return tmp_name
  end

  def pdf_url
    h = $request_host
    filename = Setting.company_name + "_enveloppe_" + self.id.to_s + ".pdf"
    return URI.parse(AppConfig.tomcat_base +
    	"Enveloppe.pdf?host=#{h}&id=#{self.id}&filename=#{filename}").to_s
  end

end
