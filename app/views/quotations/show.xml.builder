xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.devis('id' => @quotation.id ) do
	xml.date( @quotation.created_on.strftime( "%d/%m/%Y" ) )

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
	end

	xml.customer do
		xml.name( @quotation.customer.name )
		xml.addr1( @address.addr1 )
		xml.addr2( @address.addr2 )
		xml.postcode( @address.postcode )
		xml.city( @address.city )
		xml.country( @address.country.name )
	end

	@q_items.each do |q_item|
		if (q_item.product_id)
			product = Product.find( q_item.product_id )
		end
		xml.item do
			if (q_item.description)
				xml.name( q_item.description )
			else
				xml.name( product.description )
			end
			xml.qty( q_item.qty ) if q_item.qty
			xml.price( q_item.price ) if q_item.price
			xml.vat(q_item.vat) if q_item.vat
		end
	end

	if @quotation.shipping
		xml.item do
			xml.name( "Frais de port" )
			xml.qty( 1 )
			xml.price( @quotation.shipping )
			xml.vat( @quotation.shipping )
		end
	end

	if @quotation.remark
		xml.remark( @quotation.remark )
	end

	for	vr in @quotation.vat_rates
		xml.vat_subtotal do
			xml.rate( vr.rate )
			xml.value( vr.value )
		end
	end

end
