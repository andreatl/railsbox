class UsersController < ApplicationController
   
  skip_before_filter :is_authorised, :only=>[:new, :create]
  
  before_filter:check_admin, :except =>[:new, :create, :me]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end
  
  
  
  def show
    @user = User.find(params[:id])
  end
  
  def me
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
  
  
end
