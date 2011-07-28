require File.dirname(__FILE__) + '/../spec_helper'

describe 'TwitterTags' do
  dataset :pages
  
  before do
    Radiant.config['twitter.username'] = 'testy'
    Radiant.config['twitter.password'] = 'secret'
    @client = mock("HTTPAuth (client)").as_null_object
    @tweets = (1..10).collect do |i|
      mock("tweet_#{i}", 
        :text => "tweet #{i}",
        :created_at => Time.parse("Feb #{i} 2010"),
        :srouce => "<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>"
      )
    end

  end

  describe '<r:twitter> The main context' do
    it 'should give no output' do
      tag = %{<r:twitter />}
      pages(:home).should render(tag).as('')
    end
  end

  describe '<r:twitter:tweets> Collect the users recent tweets' do
    before(:each) do
      Twitter::Client.stub!(:new).and_return(@client)
      @client.stub!(:user_timeline).and_return(@tweets)
    end

    it 'should give no output' do
      tag = %{<r:twitter><r:tweets></r:tweets></r:twitter>}
      pages(:home).should render(tag).as('')
    end

    it 'should report the correct number of tweets' do
      tag = %{<r:twitter><r:tweets:length /></r:twitter>}
      pages(:home).should render(tag).as("10")
    end

    it 'should return the tweet text and replace links' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:text /></r:tweets:each></r:twitter>}
      expected = "@mattspendlove yes. Check out <a class=\"twitter_link\" href=\"http://www.cenatus.org\">http://www.cenatus.org</a>"
      pages(:home).should render(tag).as(expected)
    end
  
  
    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_at /></r:tweets:each></r:twitter>}
      expected = "Mon Dec 21 22:59:45 +0000 2009"
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created ago string' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_ago /></r:tweets:each></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      pages(:home).should render(tag).as("11 days")
    end
  
  
    it 'should return the source' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:source /></r:tweets:each></r:twitter>}
      pages(:home).should render(tag).as("<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>")
    end
  end
  
  describe '<r:twitter:list list="list"> Collect the users list tweets' do
    before(:each) do
      Twitter::Client.stub!(:new).and_return(@client)
      @client.stub!(:list_timeline).and_return(@tweets)
    end
  
    it 'should give no output' do
      tag = %{<r:twitter><r:list list="list"></r:list></r:twitter>}
      pages(:home).should render(tag).as('')
    end
  
    it 'should report the correct number of tweets (default 10)' do
      tag = %{<r:twitter><r:list list="list"><r:length /></r:list></r:twitter>}
      pages(:home).should render(tag).as("10")
    end
  
    it 'should return the tweet text and replace links' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:text /></r:each></r:list></r:twitter>}
      expected = "@mattspendlove yes. Check out <a class=\"twitter_link\" href=\"http://www.cenatus.org\">http://www.cenatus.org</a>"
      pages(:home).should render(tag).as(expected)
    end
  
  
    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_at /></r:each></r:list></r:twitter>}
      expected = "Mon Dec 21 22:59:45 +0000 2009"
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created ago string' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_ago /></r:each></r:list></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      pages(:home).should render(tag).as("11 days")
    end
  
    it 'should return the source' do
      
      p "in the last test, tweets.first is #{@tweets.first.inspect} and respond_to?(:source) is #{@tweets.first.respond_to?(:source).inspect} and source is #{tweets.first.source}"
      
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:source /></r:each></r:list></r:twitter>}
      expected = "<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>"
      pages(:home).should render(tag).as(expected)
    end
  end
end