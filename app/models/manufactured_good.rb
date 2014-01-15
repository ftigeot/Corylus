# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

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
