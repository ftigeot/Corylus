# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ContactsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  def list
    @contacts = Contact.find :all, :order => 'lastname,firstname'
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @partner = Partner.find(params[:id])
    @contact = Contact.new
    @contact.partner_id = @partner.id
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      redirect_to :controller => 'partners', :action => 'show', :id => @contact.partner_id
    else
      flash[:notice] = 'Echec de la création du contact'
      render :action => 'new_contact'
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])
    if @contact.update_attributes(params[:contact])
      redirect_to :controller => 'partners', :action => 'show', :id => @contact.partner_id
    else
      flash[:notice] = 'Echec de la mise à jour du contact'
      render :action => 'edit'
    end
  end

  def mass_mailing
    @contacts = Contact.find :all, :order => :id,
		:conditions => ['email <> ? and mailing_wanted = true', '']
    string = ''
    for contact in @contacts
      string += contact.email + "\n"
    end
    response.headers['Content-Type'] = 'text/plain'
    response.headers['Content-Disposition'] = 'attachment; filename=contact-list.txt'
    render :text => string
  end

  def mm_customers
    @contacts = Contact.find :all, :order => :id, :conditions => ['
		email <> ? and mailing_wanted = true
		AND partner_id IN (select id from partners where is_customer = TRUE)', '']
    string = ''
    for contact in @contacts
      string += contact.email + "\n"
    end
    response.headers['Content-Type'] = 'text/plain'
    response.headers['Content-Disposition'] = 'attachment; filename=customer-list.txt'
    render :text => string
  end

end
