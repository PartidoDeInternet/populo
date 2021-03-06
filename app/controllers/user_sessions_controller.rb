class UserSessionsController < ApplicationController
  before_filter :require_user, :only => :destroy
  layout "mini_application"
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "oh! adios :("
    redirect_to root_path
  end
end
