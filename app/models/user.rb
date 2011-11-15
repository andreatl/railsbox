class User < ActiveRecord::Base

  require 'haddock'
  include Haddock

  has_many :permissions, :as=>:parent
  has_many :folders
  has_many :folders, :through=>:permissions, :conditions=>['read_perms = ? or write_perms = ?', true, true]
  has_many :assets
  has_many :user_groups
  has_many :groups, :through=>:user_groups 
  has_many :logs
  
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :company, :company_contact, :can_home, :is_admin, :can_hotlink, :active
  
  scope :active, lambda {|active|
    if active != 'all'
     where('active = ' + active).order("name")
    end 
  }
  
  scope :named, lambda {|name| 
      escaped_query = "%" + name.gsub('%', '\%').gsub('_', '\_') + "%"
      where("name ILIKE ? OR first_name || ' ' || last_name ILIKE ?",escaped_query,escaped_query).order("name")
  }
  
  def name
    if first_name and last_name
      first_name.capitalize + ' ' + last_name.capitalize 
    else
      email
    end  
  end  
  
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  
  def accessible_folders_exc_groups
    if is_admin
      return Folder.scoped.order('parent_id nulls first, name')
    else
      #does not include folders from groups
      folders = []
      permissions.where('read_perms = ? OR write_perms = ?', true, true).each do |permission|
        folders << permission.folder
        #Get all folders that have inherited permissions from this folder
        permission.folder.folder_children_inheriting_permissions.each do |folderInherited|
          folders << folderInherited
        end
      end
      folders
    end
  end  
  
  def accessible_folders
    ids = (groups.map{|x| x.folders} + accessible_folders_exc_groups).flatten.map{|a| a.id}.join(',')
    Folder.where("id in (#{ids})") unless ids.blank?
  end
  
  def owned_folders
    if is_admin
      return Folder.scoped 
    else
      Folder.where(:user_id=>id)
    end
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.generate_password
     Password.generate_fun
  end
  
  def can_home?
    can_home || is_admin
  end
  
  def space_used
    assets.map{|x| x.uploaded_file_file_size}.inject(:+)
  end
  
  def space_remaining
    APP_CONFIG['user_disk_space'].to_i - space_used
  end
  
  def space_percentage
    ((space_used.to_f/APP_CONFIG['user_disk_space'].to_f)* 100).to_i
  end

end

