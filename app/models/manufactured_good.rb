# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ManufacturedGood < ActiveRecord::Base
  belongs_to :product
  has_many :mg_items, :foreign_key => 'owner_id'

  def before_create
    self.serial_number = new_serial
  end

private

  # We need easy to read serial numbers
  # => do not use 8 and B, 1 and I, 0 and O, U and V
  # incidently the accepted character count is exactly 32
  SERNUM_CHARS = %w( 0 1 2 3 4 5 6 7 8 9 A C D E F G
  					 H J K L M N P Q R S T U W X Y Z )
  MASK = 0x1f

  def serial_to_str( num )
    str=''

    8.times do
      digit = (num & MASK)
      str = SERNUM_CHARS[digit] + str
      num >>= 5
    end
    return str
  end

  # Serial number must be easy to read
  def acceptable_serial( str )
    # no more than two repeating characters
    return true
  end

  def new_serial
    num = rand(1099511627776)	# 40-bit
    return serial_to_str(num)
  end

end
