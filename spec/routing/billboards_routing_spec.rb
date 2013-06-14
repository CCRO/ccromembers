require "spec_helper"

describe BillboardsController do
  describe "routing" do

    it "routes to #index" do
      get("/billboards").should route_to("billboards#index")
    end

    it "routes to #new" do
      get("/billboards/new").should route_to("billboards#new")
    end

    it "routes to #show" do
      get("/billboards/1").should route_to("billboards#show", :id => "1")
    end

    it "routes to #edit" do
      get("/billboards/1/edit").should route_to("billboards#edit", :id => "1")
    end

    it "routes to #create" do
      post("/billboards").should route_to("billboards#create")
    end

    it "routes to #update" do
      put("/billboards/1").should route_to("billboards#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/billboards/1").should route_to("billboards#destroy", :id => "1")
    end

  end
end
