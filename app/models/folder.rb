class Folder < ActiveRecord::Base
  
  belongs_to :user  
  has_many :permissions, :dependent => :destroy
  has_many :users, :through => :permissions
  has_many :assets, :dependent => :destroy

  attr_accessible :name, :parent_id, :notes, :description, :inherit_permissions

  acts_as_tree :order => 'name'  
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:parent_id, :user_id]
    
  def breadcrumbs(stop = "")
    path = ''
    ancestors.each do |folder|
      path =  folder.name + '/' + path
      if folder.id == stop
        break
      end 
    end unless id == stop
    path << name.to_s
  end
  
  def folderChildren
    Folder.where(:parent_id => id)
  end
  
  def folder_children_inheriting_permissions
    p = folderChildren.where(:inherit_permissions => true)
    if p.count > 0
      p << p.map{|a| a.folder_children_inheriting_permissions}
    end
    p.flatten
  end
  
  def all_permissions
    p = Permission.where(:folder_id=>id)
    if (!parent.nil?) && inherit_permissions
      p << parent.all_permissions 
    end
    ids = p.flatten.map{|x| x.id}.join(',')
    ids.blank? ? [] : Permission.where("id in (#{ids})")
  end
  
  def is_shared?
    p = all_permissions # More than 1 user has permission
    p.count > 0 && (p.count > 1 || p.first.parent_type == "Group")
  end
   
  def can(option, user)
    if user.is_admin
      true
    else
      all_permissions.map{|x| 
        x if (x.parent_type=="User" && x.parent_id==user.id && x.send("#{option}_perms")) || (x.parent_type=="Group" && user.groups.map{|g|g.id}.include?(x.parent_id) && x.send("#{option}_perms"))
      }.compact.count > 0
    end
  end
  
  
  def method_missing(m, *args, &block)
    m.to_s.include?("can") ? can(m.to_s.downcase.gsub('?','').gsub('_','')[3..-1],args[0]) : super
  end


  def descendants
    descendant_folders_include_self - self
  end

  #returns all descendants that are under this folder including current folder
  def descendant_folders_include_self
    (folderChildren ? folderChildren.map{|a| a.descendant_folders_include_self} << self : self).flatten
  end
  
  def descendant_folders_include_self_can_read(user)
    descendant_folders_include_self.map{|f| f if f.canread(user)}.compact
  end
  
end