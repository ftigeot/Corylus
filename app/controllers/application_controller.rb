# Corylus - ERP software
# Copyright (c) 2005-2014 François Tigeot

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time

  MAX_SESSION_PERIOD = 14400	# 4 hours

  # PDF documents generation server
  TOMCAT_BASE = AppConfig.tomcat_base

  before_filter :session_expiry
  # Store the current URL so we can redirect back to it if necessary
  before_filter :store_locations
  before_filter :check_authorization, :except => :login
  before_filter :get_request_host
  
  def find_cart
    session[:cart] ||= Cart.new
  end

  # Store where we are
  def store_locations
    curpage = request.fullpath

    # Cas spécial: c'est la même vue que la page appelante
    return if curpage == '/products/create'

    session[:prevpage] = session[:thispage]
    session[:thispage] = curpage
  end
  
  # redirect_back
  # If a previous page is stored in the session, go back to it
  # otherwise go back to a default page
  def redirect_back(msg)
    flash[:notice] = msg unless msg.nil?
    if session[:prevpage].nil?
      redirect_to :action => 'index'
    else
      redirect_to session[:prevpage]
    end
  end

  # Cette fonction est la source de @user
  def check_authorization
    # 1. Pas d'identification pour les requêtes susceptibles d'être faites
    # par tomcat
    no_session_ok = false
    no_session_ok = true if check_tomcat_ok('quotations','devis')
    no_session_ok = true if check_tomcat_ok('delivery_slips','bdl')
    no_session_ok = true if check_tomcat_ok('invoices','facture')
    no_session_ok = true if check_tomcat_ok('addresses','envelope')
    no_session_ok = true if check_tomcat_ok('supplier_orders','bon_commande')
    no_session_ok = true if check_tomcat_ok('expense_reports','show')
    no_session_ok = true if check_tomcat_ok('partners','list_unpaid')
    return if (no_session_ok)

    # 2. les utilisateurs normaux doivent être logués
    if session[:user_id]
      @user = User.find(session[:user_id])
      redirect_to_login = false
    else
      session[:jumpto] = request.parameters
      redirect_to_login = true
    end

    # 3. Certains utilisateurs n'ont pas accès à tout
    authorized = false
    if session[:user_id]
      authorized = true
      authorized &= perm_chk( @user.perm_invoice_w, 'gescom', 'new_quotation')
      authorized &= perm_chk( @user.perm_invoice_w, 'supplier_orders', 'new')
    end

    if (redirect_to_login)
      redirect_to :controller => 'users', :action => 'login'
    else
      render :action => '../shared/unauthaurized' unless authorized
    end
  end

  # retourne vrai si autorisé à accéder à la page
  def perm_chk( flag, controller, action )
    controller_true = (self.controller_name == controller)
    action_true = (self.action_name == action)
    flag_true = (flag == true)

    return (flag_true || !(controller_true && action_true))
  end

  def session_expiry
    reset_session if session[:expiry_time] and session[:expiry_time] < Time.now
    session[:expiry_time] = MAX_SESSION_PERIOD.seconds.from_now
    return true
  end

  def get_request_host
    $request_host = request.host
  end

private

  # Connection autorisée en provenance de Tomcat ?
  def check_tomcat_ok( controller, action )
    return false if (request.remote_ip != AppConfig.tomcat_ip)
    return false if (controller_name != controller)
    return false if (action_name != action)
    return true
  end

end
