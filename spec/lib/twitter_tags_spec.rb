require File.dirname(__FILE__) + '/../spec_helper'

describe 'TwitterTags' do
  dataset :pages

  describe '<r:twitter> The main context' do

    it 'should give no output' do
      tag = %{<r:twitter />}
      expected = ''

      pages(:home).should render(tag).as(expected)
    end
  end

  describe '<r:twitter:tweets> Collect the users recent tweets' do

    before(:each) do
      @client = mock("HTTPAuth (client)").as_null_object
      Twitter::Base.stub!(:new).and_return(@client) #stub the actual remote authorisation calls
    end

    it 'should give no output' do
      tag = %{<r:twitter><r:tweets></r:tweets></r:twitter>}

      timeline = mock("timeline").as_null_object
      @client.should_receive(:user_timeline).and_return(timeline) #expect the user timeline call and return the mock

      expected = ''
      pages(:home).should render(tag).as(expected)
    end

    it 'should report the correct number of tweets (default 10)' do
      tag = %{<r:twitter><r:tweets:length /></r:twitter>}

      tweets = []
      20.times do
        tweet = mock("tweet")
        tweets << tweet
      end

      @client.should_receive(:user_timeline).and_return(tweets)

      expected = "10"
      pages(:home).should render(tag).as(expected)
    end

    it 'should report the correct number of tweets (mex 4)' do
      tag = %{<r:twitter><r:tweets max='4'><r:length /></r:tweets></r:twitter>}

      tweets = []
      20.times do
        tweet = mock("tweet")
        tweets << tweet
      end

      @client.should_receive(:user_timeline).and_return(tweets)

      expected = "4"
      pages(:home).should render(tag).as(expected)
    end

    it 'should return the tweet text and replace links' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:text /></r:tweets:each></r:twitter>}
        
      tweets = []
      tweet = mock("tweet")
      tweets << tweet
      tweet.stub!(:text).and_return("@mattspendlove yes. Check out http://www.cenatus.org")

      @client.should_receive(:user_timeline).and_return(tweets)

      expected = "@mattspendlove yes. Check out <a class=\"twitter_link\" href=\"http://www.cenatus.org\">http://www.cenatus.org</a>"
      pages(:home).should render(tag).as(expected)
    end


    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_at /></r:tweets:each></r:twitter>}

      tweets = []
      tweet = mock("tweet")
      tweets << tweet
      tweet.stub!(:created_at).and_return("Mon Dec 21 22:59:45 +0000 2009")

      @client.should_receive(:user_timeline).and_return(tweets)
      
      expected = "Mon Dec 21 22:59:45 +0000 2009"
      pages(:home).should render(tag).as(expected)
    end

    it 'should return the created ago string' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_ago /></r:tweets:each></r:twitter>}

      tweets = []
      tweet = mock("tweet")
      tweets << tweet
      tweet.stub!(:created_at).and_return(Time.parse("Feb 01 2010"))
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))

      @client.should_receive(:user_timeline).and_return(tweets)

      expected = "11 days"
      pages(:home).should render(tag).as(expected)
    end


    it 'should return the source' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:source /></r:tweets:each></r:twitter>}

      tweets = []
      tweet = mock("tweet")
      tweets << tweet
      tweet.stub!(:source).and_return("<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>")

      @client.should_receive(:user_timeline).and_return(tweets)

      expected = "<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>"
      pages(:home).should render(tag).as(expected)
    end
  end
end