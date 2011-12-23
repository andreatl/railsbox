def ask(question, hide=false)
  begin
    system "stty -echo" if hide
    puts "\n"
    puts question
    response = STDIN.gets.to_s.chomp
    system "stty echo" if hide
    return response
  rescue NoMethodError, Interrupt
    system "stty echo"
    exit
  end
end

def say(words)
  puts words
end

email     = ask "Which email do you want use for logging into admin?"
password  = ask "Tell me the password to use:", true

say ""

password_salt = BCrypt::Engine.generate_salt
password_hash = password.crypt(password_salt)

unless admin = User.find_by_email(email)
  admin = User.create(:first_name => 'admin', :last_name => 'admin', :email => email, :password_salt => password_salt, :password_hash => password_hash)
  admin.is_admin    = true
  admin.active      = true
  admin.can_home    = true
  admin.can_hotlink = true
else
  admin = nil
end

if admin
  say " ================================================================= "
  say " Account has been successfully created, now you can login with:"
  say " ================================================================= "
  say "    email:    #{email}"
  say "    password: ************"
  say " ================================================================= "
else
  say " ================================================================= "
  say " Sorry, that email address is already taken:"
  say " ================================================================= "
  say "    email:    #{email}"
  say "    password: ************"
  say " ================================================================= "
end

say ""