class Asset < ActiveRecord::Base

  belongs_to :folder
  belongs_to :user
 
  attr_accessible :user_id, :uploaded_file, :folder_id, :notes, :uploaded_file_file_name, :description
	has_attached_file :uploaded_file, :url => "/assets/get/:id", :path => "assets/:id/:basename.:extension"  
	has_many :hotlinks

  validates_attachment_presence :uploaded_file  
  
  validates_presence_of :user_id
    
  validates_uniqueness_of :uploaded_file_file_name, :scope => [:folder_id, :user_id]

  def is_authorised?(userFind)
    if folder
      folder.can("read",userFind)
      #!!userFind.accessible_folders.find_by_id(folder)
    else
      #if asset in root
      userFind == user || userFind.is_admin?
    end
  end  
  
  def permissions
    '768'
  end 
  
  def file_extension
   File.extname(uploaded_file_file_name).downcase
  end
end
