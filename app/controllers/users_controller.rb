class UsersController < ApplicationController
   
  skip_before_filter :is_authorised, :only=>[:new, :create, :resetPassword,:updatePassword]
  skip_after_filter :log, :only=>[:resetPassword, :disk_space, :searchUsersResult]
  before_filter :check_admin, :except =>[:new, :create, :me, :resetPassword,:updatePassword, :changePassword, :update]
  before_filter :mailer_set_url_options, :only=>[:create,:updatePassword]
  before_filter :get_max_users, :only => [:searchUsersResult]
  after_filter :logFilePath, :except => [:index, :new, :edit, :searchUsersResult, :resetPassword, :updatePassword, :disk_space]
  
  
  def index
    @users = User.where(:active=>true)
    @non_users = User.where(:active=>false)
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
           
    if @user.save
      
      #send email to admin
      begin
        to = APP_CONFIG['admin_email_address']
        UserMailer.user_registered(@user, to).deliver
      rescue
      end
      
      redirect_to users_url, :notice => "Signed up!"
    else
      render "new"
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def me
    @user = current_user
    render :template => 'users/show'
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = current_user
    end
    
    if @user.update_attributes(params[:user])
      if current_user.is_admin
        #allowed to change permissions
        @user.is_admin = params[:user][:is_admin] if params[:user][:is_admin]
        @user.can_hotlink = params[:user][:can_hotlink] if params[:user][:can_hotlink]
        @user.can_home = params[:user][:can_home] if params[:user][:can_home]
        @user.active = params[:user][:active] if params[:user][:active]
        if @user.save!
          redirect_to @user, :notice  => "Successfully updated."
        else
          render :action => 'show'
        end
      else
        redirect_to @user, :notice  => "Successfully updated."
      end
    else
      render :action => 'edit'
    end
  end


  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully deleted user."
  end
  
  def searchUsersResult
    @users= User.named(params[:query])
    if params[:active] != "all"
      @users = @users.active(params[:active])
    end
      @users = @users.limit(@max_users)
  end
  
  def resetPassword
  end
  
  def disk_space
  end
  
  def changePassword
    @user = current_user
  end
  
  def updatePassword
      if params[:email]
        @user = User.find_by_email(params[:email])
      end
      
      if @user
        @log_user_id = @user.id        
        newPassword = User.generate_password
        @user.password = newPassword
        @user.password_confirmation = newPassword
        if @user.save
          UserMailer.reset_password(@user, newPassword).deliver
          redirect_to log_in_path, :notice => "New password sent"
        else
          redirect_to root_path, :notice => "Password reset failed"
        end
      else
        redirect_to log_in_path, :notice => "User not found"
      end
  end
  
  private
  def logFilePath
    @log_file_path = @user.email
    @log_target_id = @user.id
  end
  
end