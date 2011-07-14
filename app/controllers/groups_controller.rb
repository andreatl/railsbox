class GroupsController < ApplicationController
  
  before_filter :check_admin
  
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      redirect_to @group, :notice => "Successfully created group."
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      redirect_to @group, :notice  => "Successfully updated group."
    else
      render :action => 'edit'
    end
  end

  def destroy
  end
  
  def searchResult
    @groupCount = Group.named(params[:query]).count
    @groups= Group.named(params[:query]).limit(5)
  end
  
  def userGroupSearchResult
    @groupCount = Group.named(params[:query]).count
    @groups = Group.named(params[:query]).limit(5)
    
    @userCount = User.named(params[:query]).count
    @users = User.named(params[:query]).limit(5)
  end
end
