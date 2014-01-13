xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.invoice('id' => @invoice.public_id ) do
	xml.date( @invoice.created_on.strftime("%d/%m/%Y") )
	xml.tag!( 'due-date', @invoice.due_date.strftime("%d/%m/%Y") ) unless (@invoice.due_date.nil?)
	xml.credit_note( @invoice.is_credit_note )

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
		xml.bic( @billing_bic )
		xml.iban( @billing_iban )
	end

	xml.customer do
		xml.name( @quotation.customer.name )
		xml.service( @address.service ) if @address.service != ''
		xml.addr1( @address.addr1 )
		xml.addr2( @address.addr2 )
		xml.postcode( @address.postcode )
		xml.city( @address.city )
		xml.country( @address.country.name )
	end

	if ((!@delivery_address.nil?) && (@delivery_address.id != @address.id))
		xml.delivery do
			xml.name( @delivery_address.company_name )
			xml.addr1( @delivery_address.addr1 )
			xml.addr2( @delivery_address.addr2 )
			xml.postcode( @delivery_address.postcode )
			xml.city( @delivery_address.city )
			xml.country( @delivery_address.country.name )
		end
	end

	order_num = @order.order_num
	order_date = @order.order_date
	if (!order_num.nil?) && (!order_date.nil?)
		xml.commande do
			xml.num( order_num ) if order_num != ""
			xml.date( order_date.strftime("%d/%m/%Y") ) if !order_date.nil?
		end
	end

	unless (@invoice.delivery_slip.nil?)
		xml.packing_slip( @invoice.delivery_slip.official_id )
	end

	if (!@invoice.advance.nil?)
		xml.advance( @invoice.advance )
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
		end
	end

		if @invoice.shipping
		xml.item do
			xml.name( "Frais de port" )
			xml.qty( 1 )
			xml.price( @invoice.shipping )
		end
	end

	for	vr in @invoice.vat_rates
		xml.vat_subtotal do
			xml.rate( vr.rate )
			xml.value( vr.value )
		end
	end

end
