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

class InterventionsController < ApplicationController

  def new
    @intervention = Intervention.new
    @customers = Customer.find :all, :order => 'name'
  end

  def create
    @intervention = Intervention.new(params[:intervention])

    Intervention.transaction do
      if @intervention.save
        flash[:notice] = 'New intervention registered.'
      else
        flash[:notice] = 'Failed to create a new intervention.'
      end
    end
    redirect_to :action => 'list'
  end

  def edit
    @intervention = Intervention.find(params[:id])
    @customers = Customer.find :all
  end

  def update
    @intervention = Intervention.find(params[:id])
    if @intervention.update_attributes(params[:intervention])
      flash[:notice] = 'Intervention record updated.'
      redirect_to :action => 'show', :id => @intervention.id
    else
      render :action => 'edit'
    end
  end

  def list
    @interventions = Intervention.find :all, :order => 'created_at'
  end

  def show
    @intervention = Intervention.find(params[:id])
  end

end
