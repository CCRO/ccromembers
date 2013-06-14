require 'spec_helper'

describe "billboards/index" do
  before(:each) do
    assign(:billboards, [
      stub_model(Billboard,
        :title => "Title",
        :body => "MyText",
        :active => false,
        :archived => false
      ),
      stub_model(Billboard,
        :title => "Title",
        :body => "MyText",
        :active => false,
        :archived => false
      )
    ])
  end

  it "renders a list of billboards" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
