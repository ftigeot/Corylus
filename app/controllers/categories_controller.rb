# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class CategoriesController < ApplicationController

  def list
    @categories = Category.find( :all, :order => 'name',
		:conditions => ["parent_id IS NULL"] )
  end

  def show
    @category = Category.find(params[:id])
    @categories = Category.find( :all, :conditions => ["parent_id = ?", @category.id ] )
    @products = Product.find :all, :conditions => ["category_id = ? and obsolete = false", params[:id]],
		:order => sort_column
  end

  def show_all
    show
    @products = Product.find :all, :conditions => ["category_id = ?", @category], :order => sort_column
	render :action => 'show'
  end

  def update_positions
    @category = Category.find(params[:id])
    Category.transaction do
      ActiveRecord::Base.record_timestamps = false
      @category.valid_products.each do |product|
        product.update_attribute( :position, params[:sortable].index(product.id.to_s) + 1 )
      end
      ActiveRecord::Base.record_timestamps = true
    end
    show
    render :action => 'show', :layout => false
  end

  def new
    @category = Category.new
    @possible_parents = Category.find :all, :order => 'name'
  end

  def create
    @category = Category.new(params[:category])
    @category.parent_id = nil if (@category.parent_id == 0)
    if @category.save
      flash[:notice] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
    @possible_parents = Category.find :all,
  		:conditions => ['id <> ?', @category.id],
  		:order => 'name'
  end

  def update
    @category = Category.find(params[:id])
    @category.attributes = params[:category]
    @category.parent_id = nil if (@category.parent_id == 0)
    if (@category.save)
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @category
    else
      render :action => 'edit'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to :action => 'list'
  end

  def sort_by
    previous_sort_column = session[:sort_column]
    session[:sort_column] = params[:column]
    flip_sort_direction if (session[:sort_column] == previous_sort_column)
    redirect_to :action => 'show', :id => params[:id]
  end

private

  def sanitize_sort_direction
    dir = session[:sort_direction]
    session[:sort_direction] = 'ASC' if ((dir != 'ASC') and (dir != 'DESC'))
  end

  def flip_sort_direction
    dir = session[:sort_direction]
    if (dir == 'ASC')
      session[:sort_direction] = 'DESC'
    else
      session[:sort_direction] = 'ASC'
    end
  end

  def sort_column
    sanitize_sort_direction
    session[:sort_column] = 'position' if (session[:sort_column].nil?)
    return session[:sort_column] + ' ' + session[:sort_direction]
  end
  
end
