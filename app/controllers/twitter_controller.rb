class TwitterController < ApplicationController
  def edit
  end
  
  def update
    config['twitter.username'] = params[:username]
    config['twitter.password'] = params[:password]
    config['twitter.url_host'] = params[:url_host]
    flash[:notice] = "Twitter settings saved."
  rescue
    flash[:error] = "Twitter settings could not be saved!"
  ensure
    redirect_to :action => 'edit'
  end
end