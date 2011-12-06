class Asset < ActiveRecord::Base

  belongs_to :folder
  belongs_to :user
 
  attr_accessible :user_id, :uploaded_file, :folder_id, :notes, :uploaded_file_file_name, :description
	has_attached_file :uploaded_file, :url => "/notassets/get/:id", :path => "assets/:id/:basename.:extension"  
	has_many :hotlinks

  validates_attachment_presence :uploaded_file  
  
  validates_presence_of :user_id
    
    
  before_validation :check_name_unique
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
  
  def check_name_unique
    self.uploaded_file_file_name = Asset.get_unique_name(self.uploaded_file_file_name, self.folder_id)
  end
    
  def self.get_unique_name(name, folder_id)
    f = Asset.where({:uploaded_file_file_name => name, :folder_id=> folder_id})
    if f.size < 1
      return name
    else
      x = name.split('.')
      x[x.size-2]+=" copy"
      new_name = x.join('.')       
      Asset.get_unique_name(new_name, folder_id)
    end
  end
end