class UsersController < ApplicationController
   
  skip_before_filter :is_authorised, :only=>[:new, :create, :resetPassword,:updatePassword]
  skip_after_filter :log, :only=>[:resetPassword, :disk_space, :searchUsersResult]
  before_filter :check_admin, :except =>[:new, :create, :me, :resetPassword,:updatePassword, :changePassword, :changePasswordUpdate]
  before_filter :mailer_set_url_options, :only=>[:create,:updatePassword]
  before_filter :get_max_users, :only => [:searchUsersResult]
  after_filter :logFilePath, :except => [:index, :new, :edit, :searchUsersResult, :changePassword, :resetPassword, :updatePassword, :disk_space]
  
  
  def index
    @users = User.where(:active=>true)
    @non_users = User.where(:active=>false)
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.is_admin = false
    @user.active = false

    if @user.save
      #send email to admin
      begin
        to = APP_CONFIG['admin_email_address']
        UserMailer.user_registered(@user, to).deliver
      rescue
      end
      
      redirect_to log_in_path, :notice => "Signed up, awaiting admin activation"
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
    if current_user.is_admin
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

  def update
    if params[:id]
      if current_user.is_admin
        @user = User.find(params[:id])
      else
        @user = current_user
      end
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
  
  def disk_space
  end
  
  def changePassword
  end
  
  def changePasswordUpdate
    @user = current_user
    if !@user.authenticate(params[:current_password])
      flash[:error] = "Current password incorrect"
      redirect_to user_password_path and return
    end
    
    @user.password = params[:new_password]
    @user.password_confirmation = params[:new_password_confirmation]
    
    if @user.save
      flash[:notice] = "Password changed"
      redirect_to my_details_path
    else
      flash[:error] = @user.errors
      render "changePassword"
    end
  end
  
  def resetPassword
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
          redirect_to reset_password_path, :notice => "Password reset failed"
        end
      else
        redirect_to reset_password_path, :notice => "E-Mail address not found"
      end
  end
  
  private
  def logFilePath
    @log_file_path = @user.email
    @log_target_id = @user.id
  end
  
end