adminUser = User.create(
  :first_name => 'admin',
  :last_name => 'admin',
  :email => 'admin@admin.com', 
  :password =>'123456', 
  :password_confirmation =>'123456'
)

adminUser.toggle! :is_admin
adminUser.toggle! :active
adminUser.toggle! :can_home