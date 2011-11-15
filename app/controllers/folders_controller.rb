class FoldersController < ApplicationController

  before_filter :find_folder, :only=> [:show, :details, :browse, :new, :download]
  
  after_filter :log_folder, :only=> [:create, :update]
  
  skip_after_filter :log, :only => :folderChildren
  
  def index
    @canHome = current_user.can_home?
    @folders = []
    Folder.where('folders.parent_id is null or folders.parent_id = 0').order(:name).each do |folder|
      if folder.canread(current_user) || folder.canWrite(current_user)
        @folders << folder
      end
    end
    if current_user.is_admin?
      @assets  = Asset.where(:folder_id=>nil).order(:uploaded_file_file_name)
    else
      @assets  = Asset.where(:folder_id=>nil, :user_id=>current_user).order(:uploaded_file_file_name)  
    end
    
    @log_action = "browse"
    @log_file_path = "/"
  end

  def show
    browse
  end

  def details
  end

  def new
    if (params[:folder_id] && @current_folder.canwrite?(current_user)) || (params[:folder_id].nil? && @current_user.can_home?)
      @folder = Folder.new
      @folder.parent_id = @current_folder.id if params[:folder_id]
    end
  end

  def create
    @folder = Folder.new(params[:folder])
    @folder.user_id = current_user.id
    @folder.inherit_permissions = true unless current_user.is_admin
    @folder.inherit_permissions = false unless @folder.parent_id?
    if @folder.save
      if @folder.parent_id?
        redirect_to browse_path(@folder.parent)  
      else  
        p = Permission.new(:assigned_by=>current_user.id, :read_perms=>true, :write_perms=>true, :delete_perms=>true, :folder_id=>@folder.id, :parent_type=>"User",:parent_id=>current_user.id) unless current_user.is_admin?
        p.save
        redirect_to root_url
      end 
    else
      render :action => 'new'
    end
  end

  def edit
    @folder = Folder.find(params[:id])
  end

  def update
    @folder = Folder.find(params[:id])
    if @folder.update_attributes(params[:folder])
      if @folder.parent.nil?
        redirect_to root_path, :notice  => "Successfully updated folder."
      else
        redirect_to @folder, :notice  => "Successfully updated folder."
      end
    else
      render :action => 'edit'
    end
  end

  def browse
    @canHome = @current_user.can_home?
    if @current_folder
      #folders
      @folders = current_user.accessible_folders.where(:parent => @current_folder).order("name")
      
      #assets
      if @current_folder.canRead?(@current_user)
        @assets = @current_folder.assets.order("uploaded_file_file_name")  
      else
        #users can see own files
        @assets = @current_folder.assets.where('user_id = ?',current_user.id).order("uploaded_file_file_name")
      end
      render :action => "index"  
    else
      flash[:error] = "Folder not found"  
      redirect_to root_url  
    end
    
    #Use find_by_id instead of find as find_by_id returns nil, rather than throwing exception
    #if @current_folder  
    #  @folders = current_user.accessible_folders.where('folders.parent_id=?',@current_folder)
    #  if current_user.is_admin or @current_folder.canRead?(@current_user)
    #    @assets = @current_folder.assets.order("uploaded_file_file_name desc")  
      #else
        #read only can still see own files.
        #@assets = @current_user.assets.order("uploaded_file_file_name desc").find_all_by_folder_id(@current_folder)
   #   end
   #   render :action => "index"  
   # else
   #   flash[:error] = "Folder not found"  
   #   redirect_to root_url  
   # end  
  end  
  
  def folderChildren
    if params[:folder_id] == '0'
      @parentFolder = nil
    else
      @parentFolder = Folder.find(params[:folder_id])
    end
    @folders = current_user.accessible_folders.where(:parent_id => @parentFolder).order(:name)
  end

  def search
    search_query = params[:search]
    @search_query = search_query[:query]
    @escaped_query = "%" + @search_query.gsub('%', '\%').gsub('_', '\_') + "%"
    @searchNotes = search_query[:notes] == '1'
    
    if @searchNotes
      @folders = current_user.accessible_folders.find(:all, :conditions => ["name ILIKE ? OR notes ILIKE ?", @escaped_query, @escaped_query])
      @assets = current_user.assets.find(:all, :conditions => ["uploaded_file_file_name ILIKE ? OR notes ILIKE ?", @escaped_query, @escaped_query])
    else
      @folders = current_user.accessible_folders.find(:all, :conditions => ["name ILIKE ?", @escaped_query])
      @assets = current_user.assets.find(:all, :conditions => ["uploaded_file_file_name ILIKE ?", @escaped_query])
    end
    
    #log
    @log_file_path = "Query: " + @escaped_query
    if @searchNotes
      @log_file_path += ", include notes"
    end
    
    render :action => "index"  
  end

  def destroy
    @folder = Folder.find(params[:id])
    @log_target_id = @folder.id
    @log_file_path = "/" + @folder.breadcrumbs
    if @folder.parent.nil?
      @redirect = root_path
    else
      @redirect = browse_path(@folder.parent)
    end
    
    @folder.destroy
    redirect_to @redirect, :notice => "Successfully deleted."
  end
  
  def find_folder
    if params[:folder_id]
      folder =  Folder.find(params[:folder_id])
    elsif params[:id]
      folder = Folder.find(params[:id])
    else
      #none to be found
    end
    
    if folder && (folder.can("read",@current_user) || folder.can("write",@current_user))
      @current_folder = folder
      @log_file_path = "/" + @current_folder.breadcrumbs
      @log_target_id = @current_folder.id.to_s
    end
    
    #if params[:folder_id]
    #  @current_folder =  current_user.accessible_folders.find_by_id(params[:folder_id])
    #elsif params[:id]
    #  @current_folder = current_user.accessible_folders.find_by_id(params[:id])
    #else
      #none to be found
    #end
  end
  
  def move
    @folders = []
    Folder.find(params[:ids].split(',')).each do |folder|
      (folder.canread?(@current_user) && folder.canwrite?(@current_user)) ? @folders << folder : flash[:error] = "Unauthorised" and redirect_to root_path and return
    end
    @log_file_path = ""
    if @folders.first.parent.nil?
      @log_file_path = "/"
    else
      @log_file_path = @folders.first.breadcrumbs + "/"
    end
    @log_target_id = @folders.collect{|a| a.id}.join(', ')
    
    if @folders.count > 1
      @log_file_path += ": "
    end    
    @log_file_path += @folders.collect{|a| a.name}.join(', ')
  end 
  
  def download
    require 'zip/zip'
    require 'zip/zipfilesystem'
    @log_file_path = ""
    t = Tempfile.new("downloadZip#{request.remote_ip}")
    Zip::ZipOutputStream.open(t.path) do |zos|
      unless params[:folders].blank?
        @downloadFolders = Folder.find(params[:folders].split(','))
        #Download each folder
        if @downloadFolders.first.parent_id.nil?
          @log_file_path << "/"
        else
          @log_file_path << @downloadFolders.first.parent.name
        end
        @log_file_path << ": "
        @downloadFolders.each do |parentFolder|
          @folders = parentFolder.descendant_folders_include_self_can_read(current_user)
          @folders.each do |folder|
            Asset.where(:folder_id => folder.id).each do |asset|
              zos.put_next_entry(asset.folder.breadcrumbs(parentFolder.id)+"/"+asset.uploaded_file_file_name)
              zos.print IO.read(asset.uploaded_file.path)
            end
          end
        end
        @log_file_path += @downloadFolders.collect{|f| f.name+"/"}.join(', ')
      end
      
      #If assets are selected
      unless params[:assets].blank?
        @log_file_path << ", "
        @assets = Asset.find(params[:assets].split(','))
        @assets.each do |asset|
          if asset.is_authorised?(current_user)
            zos.put_next_entry(asset.uploaded_file_file_name)
            zos.print IO.read(asset.uploaded_file.path)
          end
        end
        @log_file_path << @assets.collect{|a| a.uploaded_file_file_name}.join(', ')
      end
    end
    send_file t.path, :type => "application/zip", :disposition => "attachment", :filename => params[:name] + ".zip"
  end
  
  
  private
  def log_folder
    @log_file_path = "/" + @folder.breadcrumbs
    @log_target_id = @folder.id.to_s
  end
  
end
