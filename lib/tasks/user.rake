#BEFORE RUNNING THIS FILE ENSURE THAT THE SQL EXPORT DOES NOT BREAK ANY FOREIGN KEY DEPENDENCIES
#PARTICULARLY group_folder BEING CREATED BEFORE group

INPUT_FILE = 'tmp/user.sql' unless defined? INPUT_FILE
#From the SQL dump file, what do the required lines start with:
USER_START = "INSERT INTO `accounts`" unless defined? USER_START
FOLDER_START = "INSERT INTO `folders`" unless defined? FOLDER_START
GROUP_START = "INSERT INTO `groups`" unless defined? GROUP_START
USER_GROUP_START = "INSERT INTO `user_group`" unless defined? USER_GROUP_START
PERMISSION_START = "INSERT INTO `group_folder`" unless defined? PERMISSION_START
#The order which the sql dump file contains the attributes (use rails column names here). These will try to be set for each of the entries
USER_COLUMNS = ["id","login","password_hash","email","home","quota","protect","rights","disabled","expired","limitdays","first_name","last_name","country","zip","city","state","address","phone","fax","company","comments","addional1","additional2","additional3","additional4", "additional5"] unless defined? USER_COLUMNS
FOLDER_COLUMNS = ["id","name","pth","disabled","description"] unless defined? FOLDER_COLUMNS
GROUP_COLUMNS = ["id","name","gemail","disabled","description"] unless defined? GROUP_COLUMNS
USER_GROUP_COLUMNS = ["id","user_id","group_id"] unless defined? USER_GROUP_COLUMNS
PERMISSION_COLUMNS = ["id","parent_id","folder_id","rights","useCustomProtect","protect","description"] unless defined? PERMISSION_COLUMNS

require 'csv'

#Monkey patches for this rake task.
class User < ActiveRecord::Base; attr_accessor :rights; end
class Permission < ActiveRecord::Base; attr_accessor :rights; end
class String
  def split_tuples
    self[(self.index("(")+1)..-2].chomp(');').split('),(')
  end
  def get_attributes
    gsubbed = self.gsub(",'",",\"").gsub("',","\",")
    gsubbed = gsubbed.chomp("'") + "\"" if gsubbed[-1] == 39 #ends with single quote, remove it and replace with "
    CSV.parse(gsubbed).first #CSV parse returns an array of arrays, we only need first row.
  end
end

namespace :user do

  desc "Imports the users from a SQL file from old system"  
  task :import => :environment do
    #Open file
    INPUT_FILE = ALTERNATIVE_INPUT_FILE if defined?(ALTERNATIVE_INPUT_FILE)
    f = File.open(INPUT_FILE, "rb")
    f.each_line do |line|
      if line.start_with? USER_START
        parse User, USER_COLUMNS, line do |u|
          u.password_salt = u.password_hash[0..1]
          u.is_admin = u.rights.include? "w"
          u.can_hotlink = u.rights.to_s.include? "t"
          u.active = true #we assume all accounts are active
          u.can_home = u.can_hotlink
        end   
      end
      if line.start_with? PERMISSION_START
        parse Permission, PERMISSION_COLUMNS, line do |p|
          #All permissions are hereby assigned by admin to groups...
          p.parent_type = 'Group'
          p.assigned_by = 1
          p.read_perms = p.rights.include? "r"
          p.write_perms = p.rights.include? "u"
          p.delete_perms = p.rights.include? "d"
          
        end
      end
      parse Folder, FOLDER_COLUMNS, line if line.start_with? FOLDER_START
      parse Group, GROUP_COLUMNS, line if line.start_with? GROUP_START
      parse UserGroup, USER_GROUP_COLUMNS, line if line.start_with? USER_GROUP_START
    end
    f.close
  end
end

def parse klass, columns, csv
  klass.destroy_all
  for model in csv.split_tuples
    new_model = klass.new
    model.get_attributes.each_with_index do |attr, index|
       new_model.send("#{columns[index]}=", attr) if new_model.respond_to? columns[index]
    end
    if block_given?
      yield new_model
    end
    new_model.save(:validate => false) #avoid the checking of passwords
  end
end
