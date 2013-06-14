require 'spec_helper'

describe "billboards/show" do
  before(:each) do
    @billboard = assign(:billboard, stub_model(Billboard,
      :title => "Title",
      :body => "MyText",
      :active => false,
      :archived => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
