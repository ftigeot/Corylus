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

# Informations générales et statistiques
# Cette classe permet de générer des tableaux de bord pour avoir les
# informations essentielles sur l'activité de l'entreprise.

class ReportsController < ApplicationController

  # Informations sur le chiffre d'affaire réalisé
  # Comparaison par mois / trimestre et pour toute la durée de l'année
  # avec les périodes correspondantes des deux années précédentes.
  def turnover
    @today = Date.today
    unless (params[:date].nil?)
      begin
        @today = Date.civil( params[:date][:year].to_i,
  		params[:date][:month].to_i, params[:date][:day].to_i )
      rescue
        flash[:notice] = 'Date invalide'
        @today = Date.today
      end
    end

    @year = (@today.year).to_s.rjust(4,'0')
    @y_n1 = (@today.year - 1).to_s.rjust(4,'0')
    @y_n2 = (@today.year - 2).to_s.rjust(4,'0')
    month = @today.month.to_s.rjust(2,'0')
    day = @today.day.to_s.rjust(2,'0')

    # Special-case 29th February
    if ((month == '02') && (day == '29'))
      @limit_ly = "#{@y_n1}-#{month}-28"
    else
      @limit_ly = "#{@y_n1}-#{month}-#{day}"
    end
    @limit = "#{@year}-#{month}-#{day}"
    
    @total_ht_ly = sum_invoices( "#{@y_n1}-01-01", @limit_ly )
    @total_ht = sum_invoices( "#{@year}-01-01", @limit )
    @delta_ly = (@total_ht_ly != 0) ? (@total_ht / @total_ht_ly) : 2

    # le dernier jour du mois est variable suivant les années en février
    last_day = Date.new( @y_n2.to_i, month.to_i, -1).day.to_s.rjust(2,'0')
    @total_month_n2 = sum_invoices( "#{@y_n2}-#{month}-01", "#{@y_n2}-#{month}-#{last_day}" )

    last_day = Date.new( @y_n1.to_i, month.to_i, -1).day.to_s.rjust(2,'0')
    @total_month_n1 = sum_invoices( "#{@y_n1}-#{month}-01", "#{@y_n1}-#{month}-#{last_day}" )

    last_day = Date.new( @year.to_i, month.to_i, -1).day.to_s.rjust(2,'0')
    @total_month    = sum_invoices( "#{@year}-#{month}-01", "#{@year}-#{month}-#{last_day}" )
    @delta_month_n1 = (@total_month_n1 != 0) ? (@total_month / @total_month_n1) : 2

    @total_q1 = sum_invoices( "#{@year}-01-01", "#{@year}-03-31" )
    @total_q2 = sum_invoices( "#{@year}-04-01", "#{@year}-06-30" )
    @total_q3 = sum_invoices( "#{@year}-07-01", "#{@year}-09-30" )
    @total_q4 = sum_invoices( "#{@year}-10-01", "#{@year}-12-31" )

    @total_last_q1 = sum_invoices( "#{@y_n1}-01-01", "#{@y_n1}-03-31" )
    @total_last_q2 = sum_invoices( "#{@y_n1}-04-01", "#{@y_n1}-06-30" )
    @total_last_q3 = sum_invoices( "#{@y_n1}-07-01", "#{@y_n1}-09-30" )
    @total_last_q4 = sum_invoices( "#{@y_n1}-10-01", "#{@y_n1}-12-31" )

    @delta_last_q1 = (@total_last_q1 != 0) ? (@total_q1 / @total_last_q1) : 2
    @delta_last_q2 = (@total_last_q2 != 0) ? (@total_q2 / @total_last_q2) : 2
    @delta_last_q3 = (@total_last_q3 != 0) ? (@total_q3 / @total_last_q3) : 2
    @delta_last_q4 = (@total_last_q4 != 0) ? (@total_q4 / @total_last_q4) : 2
  end

  def customers_by_sales
    @today = Date.today
    year = (@today.year).to_s.rjust(4,'0')

    @invoices = Invoice.find_by_sql( ["
	SELECT i.*,q.customer_id
	FROM invoices i, orders o, quotations q
	WHERE o.id = i.order_id
	AND q.id = o.quotation_id
	AND to_char(i.created_on,'YYYY') = ?
	ORDER BY q.customer_id", year]
    )

    @sales = []
    Struct.new('Sales', :customer_id, :value)

    for invoice in @invoices
      index = @sales.index { |i| i[:customer_id] == invoice.customer_id }
      if index.nil?
        @sales << Struct::Sales.new(
          invoice.customer_id,
          invoice.total_ht
        )
      else
        @sales[index][:value] += invoice.total_ht
      end
    end
    @sales.sort! { |a,b| b[:value] <=> a[:value] }
  end

  # Détermine les quantités de produit en cours de commande par les
  # clients.
  # Problème: la structure de données ne permet pas facilement de
  # déterminer la quantité de produits livrés.
  def stock_ordered
    # 1. Bons de commande ouverts
    # Si un bon de commande est facturé, on considère qu'il a été
    # entièrement livré.
    tmp_orders = Order.find_by_sql '
	select o.* from orders o
	where not exists (
		select i.id from invoices i
		where i.order_id = o.id
		and i.ds_id IS NULL
	)
	and o.canceled = false
	order by order_date ASC'
    @orders = []
    order_ids = []
    for order in tmp_orders
      next if order.fully_charged?
      @orders << order
      order_ids << order.id
    end

    # 2. Assembler les lignes produit non livrées de ces commandes
    @lines = []
    for order in @orders
      for item in order.undelivered
        @lines << item
      end
    end

    # 3. On extrait la liste des sous-produits de chaque produit composé

  end

private

  def sum_invoices( str_beg, str_end )
    date_beg = Date.parse(str_beg)
    date_end = Date.parse(str_end)

    return ActiveRecord::Base.connection.select_value("
	select iv_turnover_dates('#{str_beg}', '#{str_end}')"
    ).to_f;
  end

end
