class TwitterController < ApplicationController
  def edit
    if request.post?
      begin
        @config['twitter.username'] = params[:username]
        @config['twitter.password'] = params[:password]
        @config['twitter.url_host'] = params[:url_host]
        flash[:notice] = "Twitter settings saved."
      rescue
        flash[:error] = "Twitter settings could not be saved!"
      end
      redirect_to :action => 'edit'
    end
  end
  
end