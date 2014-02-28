xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.bdc('id' => @order.official_id ) do

xml.date( @order.created_on.strftime("%d/%m/%Y") )
xml.username( @user.name )
xml.contact_email( @contact_email )

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
	end

	xml.distributor do
		xml.name( @supplier.name )
		xml.addr1( @supplier_address.addr1 )
		xml.addr2( @supplier_address.addr2 )
		xml.postcode( @supplier_address.postcode )
		xml.city( @supplier_address.city )
		xml.country( @supplier_address.country.name )
	end

	xml.delivery do
		xml.name( @delivery_address.company_name )
		xml.addr1( @delivery_address.addr1 )
		xml.addr2( @delivery_address.addr2 )
		xml.postcode( @delivery_address.postcode )
		xml.city( @delivery_address.city )
		xml.country( @delivery_address.country.name )
	end

	for item in @items
		xml.item do
			xml.ref( item.ref )
			xml.name( item.description )
			xml.qty( item.qty ) if item.qty
			xml.price( item.price ) if item.price
			xml.vat(item.vat) if item.vat
		end
	end

	if @order.shipping
		xml.item do
			xml.ref
			xml.name( "Frais de port" )
			xml.qty( 1 )
			xml.price( @order.shipping )
			xml.vat( @order.shipping_tr )
		end
	end

	if @order.remark
		xml.comment( @order.remark )
	end

	for vr in @order.vat_rates
		xml.vat_subtotal do
			xml.rate( vr.rate )
			xml.value( vr.value )
		end
	end

end
