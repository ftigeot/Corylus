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

class ExpenseReportsController < ApplicationController

  def new
    er = ExpenseReport.new
    er.user_id = session[:user_id]
    er.save!
    redirect_to :action => 'edit', :id => er.id
  end

  def edit
    @expense_report = ExpenseReport.find(params[:id])
    @er_items = ErItem.find :all,
	:conditions => ['er_id = ?', @expense_report.id],
	:order => 'expense_date, id'
  end

  def new_line
    er = ExpenseReport.find(params[:id])
    eri = ErItem.new
    eri.er_id = er.id
    eri.expense_date = Date.today
    eri.description = ''
    eri.payment_type = ''
    eri.vendor = ''
    eri.amount = 2.00
    unless eri.save
      flash[:notice] = 'Failed to add a new line in the expense report'
    end
    redirect_to :action => 'edit', :id => er.id
  end

  def update
    er = ExpenseReport.find(params[:id])
    er_items = ErItem.find :all, :conditions => ['er_id = ?', er.id]
    ExpenseReport.transaction do
      er_items.each do |eri|
        eri.update_attributes( params[:eri]["#{eri.id}"] )
      end
      unless er.update_attributes(params[:expense_report])
        flash[:error] = 'Option was not successfully updated.'
      end
    end
    redirect_to :action => 'edit', :id => er.id
  end

  def list
    @expense_reports = ExpenseReport.find :all, :order => 'created_on,id'
  end

  def show
    @expense_report = ExpenseReport.find(params[:id])
    @er_items = ErItem.find :all,
	:conditions => ['er_id = ?', @expense_report.id],
	:order => 'expense_date,id'

    @company_name = Setting.company_name
    @billing_address = Address.find( Setting.billing_address_id )

    src_url = url_for :controller => 'expense_reports',
		:action => 'show', :id => @expense_report.id,
		:protocol => 'http', :format => 'xml'
    fname = Setting.company_name + "_Expense_Report_" +
	@expense_report.id.to_s + ".pdf"
    @pdf_url = URI.parse(TOMCAT_BASE +
	"FopPDF?src=#{src_url}&xsl=expense-report.xsl&filename=#{fname}").to_s
    respond_to do |format|
      format.html
      format.xml { render :layout => false }
    end
  end

  def pay
    @expense_report = ExpenseReport.find(params[:id])
  end

  def paid
    @expense_report = ExpenseReport.find(params[:id])
    unless @expense_report.update_attributes(params[:expense_report])
      flash[:notice] = 'Failed to update paiement date.'
    end
    redirect_to :action => 'show', :id => @expense_report.id
  end

end
