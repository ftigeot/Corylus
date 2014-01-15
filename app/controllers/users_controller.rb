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

class UsersController < ApplicationController

  def list
    @users = User.find :all, :order => 'login'
  end

  # crée un nouveau compte utilisateur externe
  # Le mot de passe est généré automatiquement
  def create
    @customers = Customer.find :all, :order => 'login ASC'
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      @user.set_random_password
      if (@user.save)
        flash[:message] = "Nouvel utilisateur créé."
        redirect_to :action => 'list'
      else
        flash[:warning] = "Echec de la création d'un nouvel utilisateur"
      end
    end
  end

  # crée un nouveau compte utilisateur interne
  # On choisit le mot de passe
  def create_internal
    if request.get?
      @user = User.new
    else
      @user = User.new(params[:user])
      @user.partner_id = nil
      if (@user.save)
        flash[:message] = "Nouvel utilisateur créé."
        redirect_to :action => 'list'
      else
        flash[:warning] = "Echec de la création d'un nouvel utilisateur"
      end
    end
  end

  # Permet à un utilisateur existant de se connecter
  def login
    if request.get?
      session[:user_id] = nil
      @user = User.new
    else
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user_id] = logged_in_user.id
        jumpto = session[:jumpto] || { :controller => 'categories', :action => 'list' }
        logger.info "User #{@user.login} logged in"
        redirect_to jumpto
      else
        flash[:notice] = "Login unsuccessful"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:message] = 'Logged out'
    # TODO: insérer un message de log
    logger.info "User #{@user.login} logged out"
    redirect_to :action => 'login'
  end

  def forgot_password
    if request.post?
      u= User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:message]  = "A new password has been sent by email."
        redirect_to :action=>'login'
      else
        flash[:warning]  = "Couldn't send password"
      end
    end
  end

  def change_password
    @user = User.find( session[:user_id] )
    if request.post?
      test_user = User.new
      test_user.login = @user.login
      test_user.password = params[:user][:curpass]
      if (test_user.try_to_login)
        if @user.update_attributes(
    		:password => params[:user][:password],
    		:password_confirmation => params[:user][:password_confirmation] )
          flash[:notice] = 'Mot de passe changé'
        else
          flash[:notice] = 'Echec du changement de mot de passe'
        end
      else
        flash[:error] = 'Mot de passe invalide'
      end
    end
  end

end
