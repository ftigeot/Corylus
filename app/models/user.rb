# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot
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
