class CategoriesController < ApplicationController
  def index
    list
    render_action 'list'
  end

  def list
    @categories = Category.find_all
  end

  def show
    @category = Category.find(@params['id'])
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(@params['category'])
    if @category.save
      flash['notice'] = 'Category was successfully created.'
      redirect_to :action => 'list'
    else
      render_action 'new'
    end
  end

  def edit
    @category = Category.find(@params['id'])
  end

  def update
    @category = Category.find(@params['category']['id'])
    if @category.update_attributes(@params['category'])
      flash['notice'] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @category.id
    else
      render_action 'edit'
    end
  end

  def destroy
    Category.find(@params['id']).destroy
    redirect_to :action => 'list'
  end
end
