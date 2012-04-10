require 'spec_helper'

describe MicropostsController do
   render_views
  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy'
      response.should be_success
    end
  end
  
  describe "access control" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id=>1
      response.should redirect_to(signin_path)
    end
  end

  describe "PUT 'create'" do

    before(:each) do
      @user=test_sign_in(:user)
    end

    describe "failure micropost" do
      before(:each) do
        @attr={:content=>""}
      end

      it "should not create a micropost" do
        lambda do
          post :create, :micropost=>@attr
        end.should_not change(Micropost,:count).by(1)
      end

      it "should render the home page" do
        post :create, :micropost=>@attr
        response.should render_template('pages/home')
      end
    end

    describe "success" do
      before(:each) do
        @attr={:content=>"content text"}
      end

      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count)
      end

      it "should render the micropost page" do
        post :create, :micropost=>@attr
        response.should redirect_to(user_path(:user))
      end
    end

  end

end
