# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Intervention < ActiveRecord::Base
  belongs_to :customer

  # A work day is 8 hours long
  def days
    duration = ended_at - created_at
    return (duration / (8*3600)).to_i
  end

  def hours
    return 0 if (self.id.nil?)
    duration = ended_at - created_at
    half_hours = (duration / 1800).to_i
    return (half_hours / 2) + (0.5 * (half_hours % 2))
  end

end
