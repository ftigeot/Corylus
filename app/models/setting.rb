# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

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
