require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "Example User", :email => "user@example.com", :password=>"foobar", :password_confirmation=>"foobar" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user=User.new(@attr.merge(:name=>""))
    no_name_user.should_not be_valid
  end

  it "should require an email add" do
    no_email_user=User.new(@attr.merge(:email=>""))
    no_email_user.should_not be_valid
  end

  it "should reject the ling user name" do
    long_name="a"*50
    long_name_user=User.new(@attr.merge(:name=>long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validation" do
    it "should have a password" do
      User.new(@attr.merge(:password=>"",:password_confirmation=>""))
      should_not be_valid
    end

    it "should require a matching password" do
      User.new(@attr.merge(:password_confirmation=>"Invalid"))
      should_not be_valid
    end

    it "should reject short password" do
      short="a"*5
      hash=@attr.merge(:password=>short,:password_confirmation=>short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user=User.create!(@attr)
    end

    it "should have an ecrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be if password matched" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        wrong_pwd_user=User.authenticate(@attr[:email],"wrongpassword")
        wrong_pwd_user.should be_nil
      end

      it "should return nil on no user with mail address" do
        noexixt_user=User.authenticate("bar@foo.com",@attr[:password])
        noexixt_user.should be_nil
      end

      it "should return user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user=User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost association" do
    before(:each) do
      @user=User.create!(@attr)
      @mp1=Factory(:micropost, :user=>@user, :created_at=>1.day.ago)
      @mp2=Factory(:micropost, :user=>@user, :created_at=>1.hour.ago)
    end

    it "should should respond to micropost attr" do
      @user.should respond_to(:microposts)
    end

    it "should have in right order" do
      @user.microposts.should == [@mp2,@mp1]
    end

    it "should destroy associated micropost" do
      @user.destroy
      [@mp1,@mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "should have a feed" do
        @user.should respond_to(:feed)
      end

      it "should include the user's microposts" do
        @user.feed.include?(@mp1).should be_true
        @user.feed.include?(@mp2).should be_true
      end

      it "should not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end
    end
  end
end
