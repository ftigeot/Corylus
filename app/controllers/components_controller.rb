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

class ComponentsController < ApplicationController

  def list
    @product = Product.find(params[:owner_id])
    @components = @product.components
  end

  def update_positions
    @owner = Product.find(params[:owner_id])
    Component.transaction do
      ActiveRecord::Base.record_timestamps = false
      @owner.components.each do |component|
        component.update_attribute( :position,
		params[:sortable].index(component.id.to_s) + 1 )
      end
      ActiveRecord::Base.record_timestamps = true
    end
    list
    render :action => 'list', :layout => false
  end

  def update
    @owner = Product.find(params[:owner_id])
    Component.transaction do
      @owner.components.each do |component|
        old_qty = component.qty
        new_qty = params[:component][component.id.to_s]['qty'].to_i
        component.update_attribute :qty, new_qty if (new_qty != old_qty)
      end
    end
    redirect_to :controller => 'products',
		:action => 'edit_components',
		:id => @owner.id
  end

end
