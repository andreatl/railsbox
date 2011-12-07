class SessionsController < ApplicationController
  
  force_ssl :only => [:new, :create]

  skip_before_filter :is_authorised, :except=>:destroy
  
  layout "login"
  
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    @log_file_path = params[:email]
    
    if user
      if user.active
        @log_action = "Login"
        session[:user_id] = user.id
        redirect_to root_url
      else
        @log_action = "Login(Inactive User)"
        redirect_to log_in_path, :notice => "Account not active"
      end
    else
      @log_action = "Login Invalid"
      flash[:error] = "Invalid email or password"
      redirect_to log_in_path
    end
  end

  def destroy
    @log_action = "Logout"
    @log_user_id = session[:user_id]
    @log_file_path = User.find(session[:user_id]).email
    session[:user_id] = nil
    
    flash[:notice] = "Logged out!"
    redirect_to log_in_path
  end
  
end