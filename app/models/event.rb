# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class Event < ActiveRecord::Base
  belongs_to	:partner

  # Returns the text content, converting line breaks to <br/> tags
  def content
      return blah
  end

end
