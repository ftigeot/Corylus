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

class Setting < ActiveRecord::Base
  
  validates_uniqueness_of :name
  private_class_method :new, :create, :destroy, :destroy_all, :delete, :delete_all
  
  def self.method_missing(method, *args)
    option = method.to_s
    if option.include? '='
      # Set the value
      var_name = option.gsub('=', '')
      value = args.first
      s = self.find :first, :conditions => ['name = ?', var_name]
      s.value = value
      s.save!
    else
      # Get the value
      s = self.find :first, :conditions => ['name = ?', option]
      return nil if s.nil?
      return s.value
    end
  end

#  def method_missing( method, *args )
#    option = method.to_s
#    s = Setting.find :first, :conditions => ['name = ?', option]
#    return nil if s.nil?
#    return s.value
#  end

  def company_name
    s = Setting.find :first, :conditions => ['name = ?', 'company_name']
    return s.value
  end

  def bic
    s = Setting.find :first, :conditions => ['name = ?', 'bic']
    return s.value
  end

  def iban 
    s = Setting.find :first, :conditions => ['name = ?', 'iban']
    return s.value
  end

  def self.save
    @@s.save
  end

  def self.update_attributes(attributes)
    @@s.update_attributes(attributes)
  end

  def self.errors
    @@s.errors
  end

end
