xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.expense_report do

	xml.date @expense_report.created_on
	xml.user @expense_report.user.name

	xml.company do
		xml.name( @company_name )
		xml.addr1( @billing_address.addr1 )
		xml.addr2( @billing_address.addr2 )
		xml.postcode( @billing_address.postcode )
		xml.city( @billing_address.city )
		xml.country( @billing_address.country.name )
	end

	for eri in @er_items
		xml.item do
			xml.date eri.expense_date
			xml.description eri.description
			xml.merchant eri.vendor
			xml.payment eri.payment_type
			xml.amount eri.amount
			xml.vat eri.vat
		end
	end

	xml.total_amount @expense_report.total_amount
	xml.total_vat @expense_report.total_vat

end
