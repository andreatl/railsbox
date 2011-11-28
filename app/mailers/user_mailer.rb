class UserMailer < ActionMailer::Base
  
  def user_registered(user, to)
    @user = user
    mail(:from => "admin@railsbox.com", :to => to, :subject => "User Registered on Railsbox")
  end
  
  def user_activated(user)
    @user = user
    mail(:from => "admin@railsbox.com", :to => @user.email, :subject => "Railsbox Account Activated")
  end
  
  def reset_password(user,newPassword)
    @newPassword = newPassword
    @user = user
    mail(:from => "admin@railsbox.com", :to => @user.email, :subject => "Railsbox Password Reset")
  end
end