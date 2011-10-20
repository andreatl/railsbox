class Group < ActiveRecord::Base
  attr_accessible :name
  has_many :user_groups
  has_many :users, :through=>:user_groups
  has_many :permissions, :as=>:parent, :dependent => :destroy
  has_many :folders, :through=>:permissions, :conditions=>['read_perms = ? or write_perms = ?', true, true]
  
  scope :named, lambda {
    |name| 
      escaped_query = "%" + name.gsub('%', '\%').gsub('_', '\_') + "%"
      where('name ILIKE ?',escaped_query).order("name")
  }
  
  def folders
    folders = []
    permissions.where(:read_perms => true).each do |permission|
      folders << permission.folder
      permission.folder.folder_children_inheriting_permissions.each do |p| 
        folders << p
      end
    end
    folders
  end
end