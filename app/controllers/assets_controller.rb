class AssetsController < ApplicationController
  
  before_filter :isAuthorised, :except => [:new, :create, :move]

  after_filter :logFilePath, :except => [:new, :edit, :destroy, :isAuthorised]
  
  def isAuthorised
    if params[:id]
      unless Asset.find(params[:id]).is_authorised?(@current_user)
        flash[:error] = "Unauthorised"
        redirect_to root_path
        return
      end 
    elsif params[:ids]
      params[:ids].split(',').each do |asset|
        unless Asset.find(asset).is_authorised?(@current_user)
          flash[:error] = "Unauthorised"
          redirect_to root_path 
          return
        end 
      end
    end
  end
  
  def details
    @asset = Asset.find(params[:id])
    if @asset.folder.nil?
      @canWrite = current_user.can_home?
    else
      @canWrite = (@asset.folder && Folder.find(@asset.folder_id).canwrite(@current_user))
    end
  end
  
  def show
    @asset = Asset.find(params[:id])
    if @asset.folder.nil?
      @canWrite = @current_user.can_home
    else
      @canWrite = (@asset.folder && Folder.find(@asset.folder_id).canwrite(@current_user))
    end
    render :action => "details"  
  end
  
  def rename
    @asset = Asset.find(params[:asset_id])
  end

  def new
    if (params[:folder_id] && Folder.find(params[:folder_id]).canwrite?(@current_user)) || (params[:folder_id].nil? && @current_user.can_home?)
      @asset = Asset.new
      @asset.user_id = @current_user
      if params[:folder_id]
        @current_folder = Folder.find(params[:folder_id])  
        @asset.folder_id = @current_folder.id
      end
    end
  end
  
  def get  
    @asset = Asset.find_by_id(params[:id])
    if @asset  
        send_file @asset.uploaded_file.path, :type => @asset.uploaded_file_content_type, :filename => @asset.uploaded_file_file_name
    end  
  end

  def create
    @asset = Asset.new(params[:asset]) 
    unless @asset.uploaded_file_file_size.blank?
      if (@asset.uploaded_file_file_size < @current_user.space_remaining) || @current_user.is_admin?
        @asset.user_id = @current_user.id
        if @asset.save
          flash[:notice] = "File successfully uploaded"
          redirect_to (@asset.folder_id ? @asset.folder : root_path)
        else
          render :action => 'new'
        end  
      else
        flash[:error] = "You do not have enough free space"
        redirect_to (@asset.folder_id ? @asset.folder : root_path) 
      end
    else
      #no file selected
      flash[:error] = "You did not select any files"
      redirect_to (@asset.folder_id ? @asset.folder : root_path) 
    end
  end

  def edit
    @asset = Asset.find(params[:id])
  end

  def update
    @asset = Asset.find(params[:id])
    if params[:asset][:uploaded_file_file_name]
      ext = @asset.uploaded_file_file_name.split(".")[1] # get evrything before the first dot
      params[:asset][:uploaded_file_file_name] = params[:asset][:uploaded_file_file_name].split(".")[0] + "." + ext
    end
    if @asset.update_attributes(params[:asset])
      if @asset.folder_id
        redirect_to @asset.folder
      else
        redirect_to root_path
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @asset = Asset.find(params[:id])
    logFilePath
    if !@asset.folder.nil?  #if asset isnt in the root
      redirect = browse_path(@asset.folder)
    else
      redirect = root_path
    end
    @asset.destroy
    redirect_to redirect, :notice => "Successfully deleted."
  end
  
  def move
    @assets = []
    Asset.find(params[:ids].split(',')).each do |asset|
      if (asset.folder_id.nil? && current_user.can_home?) ||  (asset.folder.can("read",@current_user) && asset.folder.can("write",@current_user))
       @assets << asset
      end
    end
  end
  
  private  
  def logFilePath
    @log_file_path = ""
    if @asset and @asset.uploaded_file_file_name #1 asset selected
      @log_target_id = @asset.id.to_s
      if !@asset.folder.nil?  #if asset isnt in the root
        @log_file_path = "/" + @asset.folder.breadcrumbs
      end
      @log_file_path = @log_file_path + "/" + @asset.uploaded_file_file_name
      @log_parameters = "id=#{@asset.id}&name=#{@asset.uploaded_file_file_name}"
    elsif @assets
      @log_target_id = @assets.collect{|a| a.id}.join(', ')
      if @assets.count > 1
        if !@assets.first.folder.nil?  #if asset isnt in the root
          @log_file_path = "/" + @assets.first.folder.breadcrumbs
        end
        @log_file_path = @log_file_path + ": " + @assets.collect{|a| a.uploaded_file_file_name}.join(', ')
      else
        @log_file_path = @log_file_path + "/" + @assets.first.uploaded_file_file_name
      end
    end
  end
  
end
