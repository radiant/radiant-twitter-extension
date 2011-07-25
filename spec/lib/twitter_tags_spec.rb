require File.dirname(__FILE__) + '/../spec_helper'

describe 'TwitterTags' do
  dataset :pages
  
  let(:client) {
    mock("HTTPAuth (client)").as_null_object
  }
  let(:tweets) {
    tw = []
    20.times do
      tweet = mock("tweet")
      tweet.stub!(:text).and_return("@mattspendlove yes. Check out http://www.cenatus.org")
      tweet.stub!(:created_at).and_return("Mon Dec 21 22:59:45 +0000 2009")
      tweet.stub!(:source).and_return("<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>")
      tweet.stub!(:created_at).and_return(Time.parse("Feb 01 2010"))
      tw << tweet
    end
    tw
  }
  let(:timeline) {
    mock("timeline").as_null_object
  }
  let(:list_timeline) {
    mock("list_timeline").as_null_object
  }
  
  before do
    Radiant.config['twitter.username'] = 'testy'
    Radiant.config['twitter.password'] = 'secret'
  end

  describe '<r:twitter> The main context' do
    it 'should give no output' do
      tag = %{<r:twitter />}
      pages(:home).should render(tag).as('')
    end
  end

  describe '<r:twitter:tweets> Collect the users recent tweets' do
    before(:each) do
      Twitter::Base.stub!(:new).and_return(client) #stub the actual remote authorisation calls
    end

    it 'should give no output' do
      tag = %{<r:twitter><r:tweets></r:tweets></r:twitter>}
      client.should_receive(:user_timeline).and_return(timeline) #expect the user timeline call and return the mock
      pages(:home).should render(tag).as('')
    end

    it 'should report the correct number of tweets (default 10)' do
      tag = %{<r:twitter><r:tweets:length /></r:twitter>}
      client.should_receive(:user_timeline).and_return(tweets)
      pages(:home).should render(tag).as("10")
    end

    it 'should report the correct number of tweets (mex 4)' do
      tag = %{<r:twitter><r:tweets max='4'><r:length /></r:tweets></r:twitter>}
      client.should_receive(:user_timeline).and_return(tweets)
      pages(:home).should render(tag).as("4")
    end

    it 'should return the tweet text and replace links' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:text /></r:tweets:each></r:twitter>}
      client.should_receive(:user_timeline).and_return(tweets)
      expected = "@mattspendlove yes. Check out <a class=\"twitter_link\" href=\"http://www.cenatus.org\">http://www.cenatus.org</a>"
      pages(:home).should render(tag).as(expected)
    end


    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_at /></r:tweets:each></r:twitter>}
      client.should_receive(:user_timeline).and_return(tweets)
      expected = "Mon Dec 21 22:59:45 +0000 2009"
      pages(:home).should render(tag).as(expected)
    end

    it 'should return the created ago string' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_ago /></r:tweets:each></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      client.should_receive(:user_timeline).and_return(tweets)
      pages(:home).should render(tag).as("11 days")
    end


    it 'should return the source' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:source /></r:tweets:each></r:twitter>}
      client.should_receive(:user_timeline).and_return(tweets)
      pages(:home).should render(tag).as("<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>")
    end
  end
  
  describe '<r:twitter:list list="list"> Collect the users list tweets' do
    before(:each) do
      Twitter::Base.stub!(:new).and_return(client) #stub the actual remote authorisation calls
    end

    it 'should give no output' do
      tag = %{<r:twitter><r:list list="list"></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(list_timeline) #expect the user list_timeline call and return the mock
      pages(:home).should render(tag).as('')
    end

    it 'should report the correct number of tweets (default 10)' do
      tag = %{<r:twitter><r:list list="list"><r:length /></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      pages(:home).should render(tag).as("10")
    end

    it 'should report the correct number of tweets (max 4)' do
      tag = %{<r:twitter><r:list max='4' list="list"><r:length /></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      pages(:home).should render(tag).as("4")
    end

    it 'should return the tweet text and replace links' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:text /></r:each></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      expected = "@mattspendlove yes. Check out <a class=\"twitter_link\" href=\"http://www.cenatus.org\">http://www.cenatus.org</a>"
      pages(:home).should render(tag).as(expected)
    end


    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_at /></r:each></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      expected = "Mon Dec 21 22:59:45 +0000 2009"
      pages(:home).should render(tag).as(expected)
    end

    it 'should return the created ago string' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_ago /></r:each></r:list></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      pages(:home).should render(tag).as("11 days")
    end


    it 'should return the source' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:source /></r:each></r:list></r:twitter>}
      client.should_receive(:list_timeline).with("list").and_return(tweets)
      expected = "<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>"
      pages(:home).should render(tag).as(expected)
    end
  end
end