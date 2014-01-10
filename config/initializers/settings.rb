# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

require 'yaml'
require 'ostruct'

config = OpenStruct.new(
	YAML.load_file("#{Rails.root}/config/settings.yml")
)

::AppConfig = OpenStruct.new(config.send(Rails.env))
