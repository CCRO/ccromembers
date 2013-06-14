require 'spec_helper'

describe "billboards/new" do
  before(:each) do
    assign(:billboard, stub_model(Billboard,
      :title => "MyString",
      :body => "MyText",
      :active => false,
      :archived => false
    ).as_new_record)
  end

  it "renders new billboard form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => billboards_path, :method => "post" do
      assert_select "input#billboard_title", :name => "billboard[title]"
      assert_select "textarea#billboard_body", :name => "billboard[body]"
      assert_select "input#billboard_active", :name => "billboard[active]"
      assert_select "input#billboard_archived", :name => "billboard[archived]"
    end
  end
end
