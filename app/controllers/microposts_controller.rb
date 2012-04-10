class MicropostsController < ApplicationController

  before_filter :authenticate,:only=> [:create,:destroy]
  before_filter :authorized_user, :only => :destroy
  def index

  end

  def create
    @micropost = current_user.microposts.build(params[:micropost])
	
	#if @micropost.nil? 
	#	flash[:error]= "please enter data"
	#	redirect_to home_path
		
    #els
	if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to home_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or home_path
  end

  private

    def authorized_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to home_path if @micropost.nil?
    end

end
