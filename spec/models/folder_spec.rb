require File.dirname(__FILE__) + '/../spec_helper'

describe Folder do
  it "should not be valid without name" do
    Folder.new.should_not be_valid
  end
  
  it "should be valid" do
  	valid_folder.should be_valid
  end

  it "should not allow itself to be a parent" do
    fl = valid_folder
    fl.save
    fl.parent_id = fl.id
    fl.should_not be_valid
  end

end


def valid_folder
	Folder.new(:name=>'folder 1')
end
