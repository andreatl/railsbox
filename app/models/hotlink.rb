class Hotlink < ActiveRecord::Base
  
  belongs_to :asset
  
  belongs_to :user
  
  attr_accessible :asset_id, :link, :expiry_date, :password, :days, :user_id
  
  attr_accessor :password, :days
  
  validates_presence_of :asset_id, :link
  
  before_save :encrypt_password
  
  
  def initialize(params = {})
  	super(params)
  	self.link = "hotlink#{rand(1000)}"
  end
  
  def self.authenticate(id, password)
    link = find(id)
    if link && link.password_hash == BCrypt::Engine.hash_secret(password, link.password_salt)
      link
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
    self.expiry_date = Time.now + (days.to_i || 5).days # set expiry date while we're at it (default 5 days)
  end
  
end
