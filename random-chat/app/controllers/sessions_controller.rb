class SessionsController < ApplicationController
  def new
  end

  def create
    session[:username] = params[:username]
    redirect_to "/chatroom"
    #render :text => "Welcome #{session[:username]}!"
  end
end
