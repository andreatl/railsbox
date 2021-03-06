require 'spec_helper'

describe SessionsController do

  fixtures :all
  render_views
  
  describe "logon page" do
    it "Everyone should be able to see the logon page" do
      get :new
      response.should be_success
    end
    
    it "Should render the correct template" do
  		get :new
    	response.should render_template(:new)
    end

  	it "should redirect correct user to home page" do
      u = User.new
      u.is_admin = false
      u.active = true
   		User.stub(:authenticate).and_return(u)
   		post :create
      response.should redirect_to root_url
  	end
  
  	it "should re-render login page to bad user" do
		  User.stub(:authenticate).and_return(nil)
   		post :create
    	response.should_not redirect_to root_url
  	end
  end

end