require File.dirname(__FILE__) + '/../spec_helper'

describe 'TwitterTags' do
  dataset :pages

  before do
    Radiant.config['twitter.username'] = 'testy'
    Radiant.config['twitter.password'] = 'secret'
    
    @client = mock("HTTPAuth (client)").as_null_object
    
    # I've been getting odd failures with mock tweets
    # when they're passed into a radius context
    
    @tweets = (1..10).collect do |i|
      OpenStruct.new.tap do |tweet|
        tweet.text = "tweet #{i}"
        tweet.created_at = DateTime.new(2010, 2, i+1).to_s
        tweet.source = "<a href=\"http://www.atebits.com/\" rel=\"nofollow\">Tweetie</a>"
      end
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
      expected = @tweets.map(&:text).join('')
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_at format="%d %B" /></r:tweets:each></r:twitter>}
      expected = (1..10).map{|i| "#{'%02d' % (i+1)} February"}.join('')
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created ago string' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:created_ago /></r:tweets:each></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      expected = '10 days9 days8 days7 days6 days5 days4 days3 days2 days1 day'
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the source' do
      tag = %{<r:twitter><r:tweets:each><r:tweet:source /></r:tweets:each></r:twitter>}
      expected = @tweets.map(&:source).join('')
      pages(:home).should render(tag).as(expected)
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
      expected = @tweets.map(&:text).join('')
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created at timestamp' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_at format="%d %B" /></r:each></r:list></r:twitter>}
      expected = (1..10).map{|i| "#{'%02d' % (i+1)} February"}.join('')
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the created ago string' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:created_ago /></r:each></r:list></r:twitter>}
      Time.stub!(:now).and_return(Time.parse("Feb 12 2010"))
      expected = '10 days9 days8 days7 days6 days5 days4 days3 days2 days1 day'
      pages(:home).should render(tag).as(expected)
    end
  
    it 'should return the source' do
      tag = %{<r:twitter><r:list list="list"><r:each><r:tweet:source /></r:each></r:list></r:twitter>}
      expected = @tweets.map(&:source).join('')
      pages(:home).should render(tag).as(expected)
    end
  end
end