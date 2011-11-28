require File.dirname(__FILE__) + '/../spec_helper'

describe Asset do
  
  it "shouldn't be valid" do
  	Asset.new.should_not be_valid
  end
  
  it "should be valid with all attributes" do
  	asset = valid_asset
  	asset.should be_valid
  end
  
  it "should not allow 2 files with the same name in the same folder" do
    asset1 = valid_asset
    asset1.should_not be_valid
  	asset2 = valid_asset
  	asset2.should_not be_valid
  end
  
  it "should not allow if no user present" do
  	asset = valid_asset
  	asset.user_id = nil
  	asset.should_not be_valid
  end
  
end

def valid_asset
	Asset.new(:id => 1, :uploaded_file_file_name=>'qwerty.txt', :uploaded_file_content_type=>'text/plain', :user=>valid_user)
end

def valid_user
  User.new(:id => 1, :email => "admin@test.com", :password => "123", :password_confirmation => "123", :name => "Admin Administrator", :active => true, :can_hotlink => true, :is_admin => true, :can_home => true)
end