require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  fixtures :all
  render_views


  it "New action should show new form" do
    get :new
    response.should render_template(:new)
  end
  
  it "Should save a valid user" do
    get :new
    
  end
end
