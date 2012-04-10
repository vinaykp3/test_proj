require 'spec_helper'

describe Micropost do
  before(:each) do
    @user=Factory(:user)
    @attr={:content =>"post content"}
  end

  it "should create an instance for valid entries" do
    @user.microposts.create!(@attr)
  end

  describe "valid associations" do
    before(:each) do
      @micropost=@user.microposts.create!(@attr)
    end

    it "should have user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "micropost validations" do
    it "should require a userid" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require non blank content" do
      @user.microposts.build(:content=> "").should_not be_valid
    end

    it "should reject lengthy contents" do
      @user.microposts.build(:content=>"a"*141).should_not be_valid
    end
  end
end
