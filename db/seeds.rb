def get_email
  puts "\n"
  puts "Enter new admin email address: "
  email = STDIN.gets.to_s.chomp
  return email
end

def get_reset
  puts "\n"
  puts "Admin already exists. Do you want to reset password instead? (Y/N): "
  yes_no = STDIN.gets.to_s.chomp

  unless yes_no.upcase == "Y" or yes_no.upcase == "N"
    get_reset 
  else
    return yes_no.upcase == "Y" ? true : false
  end
end

def get_password
  begin
    puts "\n"
    puts "Enter new admin password: "
    system "stty -echo"
    password = STDIN.gets.to_s.chomp
    puts "\n"
    puts "Confirm admin password: "
    password_confirmation = STDIN.gets.to_s.chomp
    system "stty echo"

    unless password == password_confirmation
      puts "\n"
      puts "Comparing given passwords [ \e[1m\e[31mFAILED\e[0m ]"
      get_password 
    else
      puts "\n"
      puts "Comparing given passwords [ \e[1m\e[32mDONE\e[0m ]"
      return password
    end
  rescue NoMethodError, Interrupt
    system "stty echo"
    exit
  end
end

puts "\n"
puts "----------------------------------------"
puts "|      Create initial admin user       |"
puts "----------------------------------------"

email = get_email
@admins = User.where(:is_admin => true)
@default_admin = @admins.find_by_email(email)

if @default_admin
  puts "\n"
  puts "Checking for existing admin [ \e[1m\e[37mFOUND\e[0m ]"
  reset = get_reset
  if reset
    puts "\n"
    puts "Confirming reset password [ \e[1m\e[32mCOMMIT\e[0m ]"
    password = get_password
    password_salt = BCrypt::Engine.generate_salt
    password_hash = password.crypt(password_salt)
  
    if @default_admin.update_attributes(:password_hash => password_hash, :password_salt => password_salt)
      puts "Resetting admin password [ \e[1m\e[32mDONE\e[0m ]"
    else
      puts "Resetting admin password [ \e[1m\e[31mFAILED\e[0m ]"
    end
  else
    puts "\n"
    puts "Confirming reset password [ \e[1m\e[31mABORT\e[0m ]"
  end
else
  puts "Checking for existing admin [ \e[1m\e[37mNONE\e[0m ]"
  password = get_password
  password_salt = BCrypt::Engine.generate_salt
  password_hash = password.crypt(password_salt)

  adminUser = User.create(
    :first_name => 'admin',
    :last_name => 'admin',
    :email => email,
    :password_salt => password_salt,
    :password_hash => password_hash
  )
  adminUser.is_admin = true
  adminUser.active = true
  adminUser.can_home = true
  adminUser.can_hotlink = true

  if adminUser.save
    puts "Creating default admin user [ \e[1m\e[32mDONE\e[0m ]"
  else
    puts "Creating default admin user [ \e[1m\e[31mFAILED\e[0m ]"
  end
end

puts "\n"