class Hotlink < ActiveRecord::Base
  
  belongs_to :asset
  
  belongs_to :user
  
  attr_accessible :asset_id, :link, :expiry_date, :password, :days, :user_id
  
  attr_accessor :password, :days
  
  validates_presence_of :asset_id
  validates_presence_of :link
  validates_uniqueness_of :link
  
  before_save :encrypt_password
  
  def initialize(params = {})
  	super(params)
  end
  
  def self.authenticate(id, password)
    link = find(id)
    if link && link.password_hash == BCrypt::Engine.hash_secret(password, link.password_salt)
      link
    else
      nil
    end
  end
  
  def self.generate_link
    f = ('a'..'z').to_a.concat(('A'..'Z').to_a.concat(('0'..'9').to_a)).sort_by{rand}.to_s[0..31]
    if Hotlink.where(:link=>f).count > 0 
      return Hotlink.generate_link
    else
      f
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
