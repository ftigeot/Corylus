xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.envelope do

	xml.orig do
		xml.name( Setting.company_name )
		xml.addr1( @orig.addr1 )
		xml.addr2( @orig.addr2 )
		xml.postcode( @orig.postcode )
		xml.city( @orig.city )
		xml.country( @orig.country.name )
	end

	xml.dest do
		xml.name( @address.partner.name )
		xml.service( @service )
		xml.addr1( @address.addr1 )
		xml.addr2( @address.addr2 )
		xml.postcode( @address.postcode )
		xml.city( @address.city )
	end

end
