xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.statement do

	xml.date( @today.strftime("%d/%m/%Y") )

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
	end

	xml.customer do
		xml.name( @partner.name )
		xml.service( @p_address.service ) if @p_address.service != ''
		xml.addr1( @p_address.addr1 )
		xml.addr2( @p_address.addr2 )
		xml.postcode( @p_address.postcode )
		xml.city( @p_address.city )
		xml.country( @p_address.country.name )
	end

	for invoice in @invoices
		if (invoice.due_date.nil?)
			due_date = invoice.created_on.strftime("%d/%m/%Y") 
		else
			due_date = invoice.due_date.strftime("%d/%m/%Y") 
		end
		advance = invoice.advance.nil? ? 0 : invoice.advance
		unpaid = invoice.total_ttc - advance

		xml.invoice do
			xml.num( invoice.public_id )
			xml.date( invoice.created_on.strftime("%d/%m/%Y") )
			xml.order_num( invoice.order.order_num )
			xml.due_date( due_date )
			xml.sum( invoice.total_ttc )
			xml.unpaid( unpaid )
		end
	end

	xml.unpaid_sum( @unpaid_sum )

end
