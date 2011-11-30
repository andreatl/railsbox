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
    asset1.should be_valid
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
  user = valid_user
  user.save
	Asset.new(:id => 1, :uploaded_file_file_name=>'qwerty.txt', :uploaded_file_content_type=>'text/plain', :user_id=>user.id)
end

def valid_user
  User.new(:name=>'foobar', :email=>'test@testemail.com',:password=>'test1', :password_confirmation=>'test1')
end