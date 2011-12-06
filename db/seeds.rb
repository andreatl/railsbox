User.delete_all

puts "Deleted existing users"

adminUser = User.create(
  :first_name => 'admin',
  :last_name => 'admin',
  :email => 'admin@admin.com', 
  :password =>'123456', 
  :password_confirmation =>'123456'
)

puts "Created admin user"

adminUser.is_admin = true
adminUser.active = true
adminUser.can_home = true
adminUser.can_hotlink = true

adminUser.save

puts "Set admin permissions"