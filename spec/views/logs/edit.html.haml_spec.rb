require 'spec_helper'

describe "logs/edit.html.haml" do
  before(:each) do
    @log = assign(:log, stub_model(Log,
      :user_id => 1,
      :event => "",
      :file_path => "MyString",
      :ip_address => "MyString",
      :user_agent => "MyString"
    ))
  end

  it "renders the edit log form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => logs_path(@log), :method => "post" do
      assert_select "input#log_user_id", :name => "log[user_id]"
      assert_select "input#log_event", :name => "log[event]"
      assert_select "input#log_file_path", :name => "log[file_path]"
      assert_select "input#log_ip_address", :name => "log[ip_address]"
      assert_select "input#log_user_agent", :name => "log[user_agent]"
    end
  end
end
