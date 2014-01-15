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

class QItemsController < ApplicationController

  def show
    @q_item = QItem.find(params[:id])
  end

  def new
    @q_item = QItem.new
  end

  def create
    @q_item = QItem.new(params[:q_item])
    if @q_item.save
      flash[:notice] = 'QItem was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @q_item = QItem.find(params[:id])
  end

  def update
    @q_item = QItem.find(params[:id])
    if @q_item.update_attributes(params[:q_item])
      flash[:notice] = 'QItem was successfully updated.'
      redirect_to :action => 'show', :id => @q_item
    else
      render :action => 'edit'
    end
  end

  def destroy
    QItem.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def move_up
    @q_item = QItem.find(params[:id])
    @q_item.move_higher
    redirect_to :controller => 'quotations', :action => 'edit', :id => @q_item.quotation_id
  end

  def move_down
    @q_item = QItem.find(params[:id])
    @q_item.move_lower
    redirect_to :controller => 'quotations', :action => 'edit', :id => @q_item.quotation_id
  end

end
