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

require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :partner
  validates_presence_of :login, :email, :password
  validates_length_of :login, :within => 3..16
  validates_length_of :password, :within => 6..20
  validates_uniqueness_of :login, :email
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Invalid email address'

  attr_protected :id, :salt

  attr_accessor :password

  def before_save
    self.hashed_password =  User.hash_password(self.password)
  end

  def after_save
    @password = nil
  end

  def self.login( login, password )
    hashed_password = hash_password( password || '' )
    find :first, :conditions => ['login = ? and hashed_password = ?',
		login, hashed_password]
  end

  def try_to_login
    User.login( self.login, self.password )
  end

  def set_random_password
    self.password = random_string(8)
  end

protected

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

private

  def random_string(len)
    # generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.hash_password( password )
    Digest::SHA1.hexdigest(password)
  end

end
