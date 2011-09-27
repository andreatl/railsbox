class SessionsController < ApplicationController
  
  skip_before_filter :is_authorised, :except=>:destroy
  
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
      redirect_to log_in_path, :notice => "Invalid email or password"
    end
  end

  def destroy
    @log_action = "Logout"
    @log_user_id = session[:user_id]
    @log_file_path = User.find(session[:user_id]).email
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end