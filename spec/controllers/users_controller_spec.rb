require 'spec_helper'

describe UsersController do
   render_views
   describe "GET 'index'" do
     it "should be success" do
       get 'index'
       response.should be_success
     end

     it "should have right title" do
       get :index
       response.should have_selector('title',:content => "All Users")
     end
   end

   describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

   # it "should have right title" do
      #get 'new'
      #response.should have_selector("title", :content=>"Sign Up")
    #end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should display users microposts" do
      mp1=Factory(:micropost,:user=>@user,:content=>"foobarx")
      mp2=Factory(:micropost,:user=>@user,:content=>"second post")
      get :show, :id=>@user
      response.should have_selector("span.content",:content=>mp1.content)
      response.should have_selector("span.content",:content=>mp2.content)
    end
  end

  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr={:name=>"", :email=>"", :password=>"", :password_confirmation=>""}
      end

      it "should not create a user" do
        lambda do
           post :create, :user =>@attr
        end.should_not change(User,:count)
      end

      it "should have the right title" do
          post :create, :user => @attr
          response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user=Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id=>@user
      response.should be_success
    end

    it "should have right title" do
      get :edit, :id=>@user
      response.should have_selector('title', :content=>"Edit User")
    end

    it "should have a link to change the gravatar image" do
      get :edit, :id=>@user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user=Factory(:user)
      test_sign_in(@user)
    end

    describe "failure update" do
      before(:each) do
        @attr={:name=>"",:email=>"",:password=>"",:password_confirmation=>""}
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success update" do
      before(:each) do
        @attr={:name =>"New Name", :email=>"user@example.org",:password=>"barbaz",:password_confirmation=>"barbaz"}
      end

      it "should change the user attributes" do
        put :update, :id=>@user, :user=>@attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the show user page" do
        put :update, :id=>@user, :user=>@attr
        response.should redirect_to(user_path(@user))
      end

      it "should should have flash message" do
        put :update, :id=>@user, :user=>@attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed in users" do
      before(:each) do
        wrong_user=Factory(:user,:email=>"user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching user for 'edit'" do
        get :edit, :id=>@user
        response.should redirect_to(home_path)
      end

      it "should require matching user for 'update'" do
        put :update, :id=>@user, :user=>{}
        response.should redirect_to(home_path)
      end
    end
  end

end
