# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class OptionsController < ApplicationController

  def new
    option = Option.new
    option.name = 'Nouvelle option'
    option.description = 'Description de la nouvelle option'
	option.save!
    redirect_to :action => 'list'
  end

  def list
    @options = Option.find( :all, :order => :id )
  end

  def edit
    @categories = Category.find :all, :order => 'name'
    @product = Product.find :first
    @option = Option.find( params[:id] )
    @option_values = OptionValue.find :all,
	:conditions => ['option_id = ?', @option.id], :order => 'position'
  end

  def new_value_text
    @option = Option.find( params[:id] )
    @option_values = OptionValue.find :all,
	:conditions => ['option_id = ?', @option.id], :order => 'position'
    option_value = OptionValue.new
    option_value.option = @option
    option_value.name = ''
    option_value.price = +50.00
    if option_value.save
      flash[:notice] = 'Nouvelle valeur créée'
    else
      flash[:notice] = 'Echec'
    end
    @option_values << option_value
    render :layout => false, :partial => 'edit_values'
  end

  def new_value_product
    @option = Option.find( params[:id] )
    selected_product = Product.find( params[:selected_product][:id] )
    @option_values = OptionValue.find :all,
	:conditions => ['option_id = ?', @option.id], :order => 'position'
    option_value = OptionValue.new
    option_value.option_id = @option.id
    option_value.product_id = selected_product.id
    if option_value.save
      flash[:notice] = 'Nouvelle valeur créée'
    else
      flash[:notice] = 'Echec'
    end
    @option_values << option_value
    redirect_to :action => 'edit', :id => @option.id
  end

  def update
    edit
    @option.name = params[:option][:name]
    @option.description = params[:option][:description]
    Option.transaction do
      @option_values.each do |ov|
        ov.update_attributes( params[:option_value]["#{ov.id}"] )
      end
      unless @option.update_attributes(params[:option])
        flash[:error] = 'Option was not successfully updated.'
      end
    end
    render :action => 'edit'
  end

  def remove_value
    option = Option.find( params[:id] )
    OptionValue.delete( params[:opval] )
    redirect_to :action => 'edit', :id => option.id
  end

end
