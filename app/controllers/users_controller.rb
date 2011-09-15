class UsersController < ApplicationController
   
  skip_before_filter :is_authorised, :only=>[:new, :create, :resetPassword,:updatePassword]
  before_filter :check_admin, :except =>[:new, :create, :me, :resetPassword,:updatePassword]
  before_filter :mailer_set_url_options, :only=>[:create,:updatePassword]
  skip_after_filter :log, :only => [:searchUsersResult]
  after_filter :logFilePath, :except => [:index, :new, :edit, :searchUsersResult, :resetPassword, :updatePassword]
  
  
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
        config = File.open('config.txt', 'r')
        to = config.readlines[0].chomp
        config.close
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
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      if current_user.is_admin
        #allowed to change permissions
        @user.is_admin = params[:user][:is_admin]
        @user.can_hotlink = params[:user][:can_hotlink]
        @user.active = params[:user][:active]
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
    if params[:inactive]
      @users = @users.inactive
    end
      @users = @users.limit(5)
  end
  
  def resetPassword
  end
  
  def updatePassword
      @user = User.find_by_email(params[:email])
      if @user
        
        newPassword = User.generate_password
        
        @user.update_attributes(:password => newPassword, :confirm_password => newPassword)
        
        UserMailer.reset_password(@user, newPassword).deliver
        
        redirect_to log_in_path, :notice => "New password sent"
      else
        redirect_to reset_password_path, :notice => "User not found"
      end
  end
  
  private
  def logFilePath
    @log_file_path = @user.email
    @log_target_id = @user.id
  end
  
end