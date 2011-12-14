require 'spec_helper'

describe Hotlink do
  
  
  it "should not be valid" do
    Hotlink.new.should_not be_valid
  end
  
  it "should be valid" do
    valid_hotlink.should be_valid  
  end

  it "should not accept a nil asset" do
    link = valid_hotlink
    link.asset_id = nil
    link.should_not be_valid
  end 
  
  it "should accept link with no password" do
    link = valid_hotlink
    link.password = nil
    link.should be_valid #still
  end

  it "should not allow the same link twice" do
    link = valid_hotlink 
    link.save
    link2 = valid_hotlink
    link2.link = link.link
    link2.should_not be_valid
  end

end


def valid_hotlink
  Hotlink.new(:name=>'foobar', :asset_id => 1, :password=>'test1');
end
