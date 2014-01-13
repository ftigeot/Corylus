xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.bdl('id' => @dslip.official_id ) do
	xml.date( @dslip.created_on.strftime("%d/%m/%Y")  )

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
	end

	xml.customer do
		xml.name( @dest_name )
		xml.service( @address.service )
		xml.addr1( @address.addr1 )
		xml.addr2( @address.addr2 )
		xml.postcode( @address.postcode )
		xml.city( @address.city )
		xml.country( @address.country.name )
	end

	if (!@order_num.nil?) or (!@order_date.nil?)
		xml.commande do
			xml.num( @order_num ) if @order_num != ""
			xml.date( @order_date.strftime("%d/%m/%Y") ) if !@order_date.nil?
		end
	end

	@items.each do |item|
		next if (item.ordered == 0)
		next if (item.delivered == 0)

		xml.item do
			xml.name( item.description )
			xml.qty( item.delivered )
		end
	end

end
