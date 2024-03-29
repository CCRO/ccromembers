require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe BillboardsController do

  # This should return the minimal set of attributes required to create a valid
  # Billboard. As you add validations to Billboard, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "title" => "MyString" }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BillboardsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all billboards as @billboards" do
      billboard = Billboard.create! valid_attributes
      get :index, {}, valid_session
      assigns(:billboards).should eq([billboard])
    end
  end

  describe "GET show" do
    it "assigns the requested billboard as @billboard" do
      billboard = Billboard.create! valid_attributes
      get :show, {:id => billboard.to_param}, valid_session
      assigns(:billboard).should eq(billboard)
    end
  end

  describe "GET new" do
    it "assigns a new billboard as @billboard" do
      get :new, {}, valid_session
      assigns(:billboard).should be_a_new(Billboard)
    end
  end

  describe "GET edit" do
    it "assigns the requested billboard as @billboard" do
      billboard = Billboard.create! valid_attributes
      get :edit, {:id => billboard.to_param}, valid_session
      assigns(:billboard).should eq(billboard)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Billboard" do
        expect {
          post :create, {:billboard => valid_attributes}, valid_session
        }.to change(Billboard, :count).by(1)
      end

      it "assigns a newly created billboard as @billboard" do
        post :create, {:billboard => valid_attributes}, valid_session
        assigns(:billboard).should be_a(Billboard)
        assigns(:billboard).should be_persisted
      end

      it "redirects to the created billboard" do
        post :create, {:billboard => valid_attributes}, valid_session
        response.should redirect_to(Billboard.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved billboard as @billboard" do
        # Trigger the behavior that occurs when invalid params are submitted
        Billboard.any_instance.stub(:save).and_return(false)
        post :create, {:billboard => { "title" => "invalid value" }}, valid_session
        assigns(:billboard).should be_a_new(Billboard)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Billboard.any_instance.stub(:save).and_return(false)
        post :create, {:billboard => { "title" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested billboard" do
        billboard = Billboard.create! valid_attributes
        # Assuming there are no other billboards in the database, this
        # specifies that the Billboard created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Billboard.any_instance.should_receive(:update_attributes).with({ "title" => "MyString" })
        put :update, {:id => billboard.to_param, :billboard => { "title" => "MyString" }}, valid_session
      end

      it "assigns the requested billboard as @billboard" do
        billboard = Billboard.create! valid_attributes
        put :update, {:id => billboard.to_param, :billboard => valid_attributes}, valid_session
        assigns(:billboard).should eq(billboard)
      end

      it "redirects to the billboard" do
        billboard = Billboard.create! valid_attributes
        put :update, {:id => billboard.to_param, :billboard => valid_attributes}, valid_session
        response.should redirect_to(billboard)
      end
    end

    describe "with invalid params" do
      it "assigns the billboard as @billboard" do
        billboard = Billboard.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Billboard.any_instance.stub(:save).and_return(false)
        put :update, {:id => billboard.to_param, :billboard => { "title" => "invalid value" }}, valid_session
        assigns(:billboard).should eq(billboard)
      end

      it "re-renders the 'edit' template" do
        billboard = Billboard.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Billboard.any_instance.stub(:save).and_return(false)
        put :update, {:id => billboard.to_param, :billboard => { "title" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested billboard" do
      billboard = Billboard.create! valid_attributes
      expect {
        delete :destroy, {:id => billboard.to_param}, valid_session
      }.to change(Billboard, :count).by(-1)
    end

    it "redirects to the billboards list" do
      billboard = Billboard.create! valid_attributes
      delete :destroy, {:id => billboard.to_param}, valid_session
      response.should redirect_to(billboards_url)
    end
  end

end
