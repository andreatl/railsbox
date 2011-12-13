require 'rake'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../../config/environment", __FILE__)
require 'rspec/rails'

describe "Should import correctly" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    load "lib/tasks/user.rake" 
    Rake::Task.define_task(:environment)
    ALTERNATIVE_INPUT_FILE = "spec/tasks/testsql.sql" unless defined? ALTERNATIVE_INPUT_FILE
    f = File.open(ALTERNATIVE_INPUT_FILE, "w")
    f.puts "irrelevant line"
    f.puts "INSERT INTO `accounts` VALUES (1,'admin','adminpass','email@email.com','foo',NULL,'foo','u,r,z,m,o,a,t,c,p,k,n,w,l,d','','','','','','','','','','','tel','','','','',NULL,NULL,NULL,NULL);"
    f.puts "irrelevant line"
    f.puts "INSERT INTO `folders` VALUES (1,'Folder one','irr',NULL,'Desc'),(2,'Folder two','irr',NULL,'Desc');"
    f.puts "irrelevant line"
    f.puts "irrelevant line"
    f.puts "INSERT INTO `groups` VALUES (1,'adminGroup','',NULL,''),(2,'TestGroup','',NULL,''),(3,'OtheRGroup','',NULL,'');"
    f.puts "irrelevant line"
    f.puts "INSERT INTO `group_folder` VALUES (1,1,1,'u,r,o,a,v',NULL,'','');"
    f.puts "irrelevant line"
    f.puts "INSERT INTO `user_group` VALUES (1,1,1);"
    f.puts "irrelevant line"
    f.puts "irrelevant line"
    f.puts "irrelevant line"
    f.close
    @rake["user:import"].invoke
  end
  after(:each) do
    Rake.application = nil
  end
 
  it "should import users correctly" do
    user = User.find(1)
    user.is_admin.should be_true
    user.can_home.should be_true
    user.password_hash.should == 'adminpass'
    user.password_salt.should == 'ad'
  end 
  
  it "should import folders correctly" do
    Folder.find(1).name.should == 'Folder one'
    Folder.find(2).name.should == 'Folder two'
  end
  
  it "should import groups correctly" do
    Group.find(1).name.should == 'adminGroup'
  end
  
  it "should import permissions correctly" do
    p = Permission.find(1)
    p.parent_id.should == 1
    p.parent_type.should == 'Group'
    p.read_perms.should be_true
  end
  
  it "should import user groups correctly" do
    UserGroup.find(1).user_id.should == 1
  end
end