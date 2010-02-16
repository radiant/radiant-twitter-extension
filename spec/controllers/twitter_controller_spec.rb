require File.dirname(__FILE__) + '/../spec_helper'
require 'twitter_controller'
TwitterController.class_eval { def rescue_action(e) raise e; end }

describe TwitterController, :type => :controller do
  controller_name 'twitter'
  scenario :users
  before :each do
    login_as :existing
  end
  
  describe "GET to /admin/twitter" do
    def do_get
      get :edit
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render the edit template" do
      do_get
      response.should render_template('edit')
    end
  end

  describe "POST to /admin/twitter" do
    before :each do
      @config = Radiant::Config
    end

    def do_post(options={})
      post :edit, {:username => "radiant", :password => "radiant", :url_host => "radiantcms.org"}.merge(options)
    end

    it "should set the flash notice when successful" do
      do_post
      flash[:notice].should_not be_nil
    end

    it "should set the flash error when unsuccessful" do
      @config.should_receive(:[]=).and_raise("Boom!")
      do_post
      flash[:error].should_not be_nil
    end

    it "should redirect back to edit" do
      do_post
      response.should be_redirect
      response.should redirect_to(twitter_path)
    end

    it "should set the username" do
      do_post :username => "sean"
      @config['twitter.username'].should == 'sean'
    end

    it "should set the password" do
      do_post :password => "foobar"
      @config['twitter.password'].should == "foobar"
    end

    it "should set the url host" do
      do_post :url_host => "radiantcms.tv"
      @config['twitter.url_host'].should == 'radiantcms.tv'
    end
  end
end