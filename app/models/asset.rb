class Asset < ActiveRecord::Base

  belongs_to :folder
  belongs_to :user
	has_many :hotlinks, :dependent => :destroy

  attr_accessible :user_id, :uploaded_file, :folder_id, :notes, :uploaded_file_file_name, :description

  has_attached_file :uploaded_file, :url => "/assets/get/:id", :path => "assets/:id/:random_file_name.:extension"

  before_validation :check_name_unique
  before_create :generate_random_file_name

  validates_attachment_presence :uploaded_file
  validates_presence_of :user_id
  validates_uniqueness_of :uploaded_file_file_name, :scope => [:folder_id, :user_id]

  def is_authorised?(userFind)
    if folder
      folder.can("read",userFind)
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
    self.uploaded_file_file_name = Asset.get_unique_name(uploaded_file_file_name, self.folder_id, self.id)
  end

  def self.get_unique_name(name, folder_id, i=nil)
    f = Asset.where({:uploaded_file_file_name => name, :folder_id=> folder_id})
    f = f.where("id != ?", i) if i
    if f.size < 1
      return name
    else
      x = name.split('.')
      x[x.size-2]+=" copy"
      new_name = x.join('.')
      Asset.get_unique_name(new_name, folder_id)
    end
  end

  def generate_random_file_name
    alphanumerics = ('a'..'z').to_a.concat(('A'..'Z').to_a.concat(('0'..'9').to_a))
    self.file_name = alphanumerics.sort_by{rand}.to_s[0..31]

    # Ensure uniqueness of the token..
    generate_random_file_name unless Asset.where(:uploaded_file_file_name => @key).count == 0
  end

  Paperclip.interpolates :random_file_name do |attachment, style|
    attachment.instance.file_name
  end

end