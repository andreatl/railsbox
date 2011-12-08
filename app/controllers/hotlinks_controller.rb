class HotlinksController < ApplicationController
  
  before_filter :check_hotlink, :except=>[:show, :update]
  
  before_filter :check_admin, :only=> [:index]

  skip_before_filter :is_authorised, :only=>[:show,:update] #can view hotlink without login
  
  after_filter :logFilePath, :except=>[:new, :index]
  
  def index
    @hotlinks = Hotlink.all
  end

  def show
    @hotlink = Hotlink.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def new
    redirect_to root_path and return unless params[:asset_id]
    @hotlink = Hotlink.new
    @hotlink.asset_id = params[:asset_id]
  end

  def create
    @hotlink = Hotlink.new(params[:hotlink])
    
    if @hotlink.save
      respond_to do |format|
        format.html {render :action => 'link' }
        format.js { render :action => 'link', :layout => false }
      end
    else
      render :action => 'new'
    end
  end
  
  def link
    @hotlink = Hotlink.find(params[:hotlink_id])
  end
  
  def update
    #Download
    @hotlink = Hotlink.authenticate(params[:id], params[:hotlink][:password])
    @log_action = "Access"
    
    if @hotlink
      send_file @hotlink.asset.uploaded_file.path, :type => @hotlink.asset.uploaded_file_content_type, :filename => @hotlink.asset.uploaded_file_file_name
    else
      @hotlink = Hotlink.find(params[:id])
      @log_action += " - Invalid Password"
      flash.now.alert = "Invalid password"
      render "show"
    end
  end
  
  private
  def logFilePath
    @log_file_path = ""
    
    if @hotlink.asset 
      @log_file_path = @hotlink.asset.folder.breadcrumbs if !@hotlink.asset.folder.nil?
      @log_file_path << "/" + @hotlink.asset.uploaded_file_file_name
    else
    	@log_file_path << "Not known"
    end	

    @log_target_id = @hotlink.id
  end

end