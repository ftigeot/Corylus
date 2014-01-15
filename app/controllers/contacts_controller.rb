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
