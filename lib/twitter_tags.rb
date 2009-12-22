require 'twitter'
module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  desc %{
    Usage:
    <pre><code><r:twitter:message  [max="10"] /></code></pre>
    Displays the latest status message from the current user's timeline. If you require finer grained control please use the individual tags like:
  <r:twitter>
    <r:tweets:each>
      <div class="tweet">
        <p class="text">
          <r:tweet:text />
          <br/> <r:tweet:created_ago /> ago from <r:tweet:source />
        </p>
      </div>
    </r:tweets:each>
  </r:twitter }
  tag 'twitter:message' do |tag|
    max=tag.attr['max'].to_i
    out = ""
    twitter_status(max).each do |status|
      text = replace_links
      out << "<p class=\"twitter_tweet\"><a class=\"twitter_user\" href=\"http://twitter.com/#{status.user.screen_name}\">#{status.user.screen_name}</a> #{text} <span class=\"twitter_time\">#{time_ago_in_words(status.created_at)} ago from #{status.source}</span></p>\n"
    end
    out
  end

  desc %{
    Usage:
    Displays the tweets from the current user's timeline:
  <r:twitter>
    <r:tweets max="10">
      <r:each>
        <div class="tweet">
          <p class="text">
            <r:tweet:text />
            <br/> <r:tweet:created_ago /> ago from <r:tweet:source />
          </p>
        </div>
      </r:each>
    </r:tweets>
  </r:twitter

  <br/>
  You can simply just use <pre><code><r:twitter:message  [max="10"] /></code></pre> if you don't require fine grained control.
  }
  tag 'twitter' do |tag|
    tag.expand
  end
  
  desc %{
    Context for the twitter tags. <br />
    The user account defined in the Radiant config keys "twitter.password", "twitter.username" and "twitter.url_host" will be accessed.
  }
  tag 'twitter' do |tag|
    tag.locals.client = twitter_login
    tag.expand
  end

  desc %{
    Retrieve a users recent tweets, optional max, default 10. Usage:
    <pre><code><r:twitter:tweets  [max="10"] /></code></pre>
  }
  tag 'twitter:tweets' do |tag|  
    tag.locals.max = tag.attr['max'].blank? ? 9 : tag.attr['max'].to_i - 1
    tag.locals.tweets = tag.locals.client.user_timeline[0..(tag.locals.max)]
    tag.expand
  end

  desc %{
    Returns the number of tweets.
  }
  tag 'twitter:tweets:length' do |tag|
    tag.locals.tweets.length
  end

  desc %{
    Loops through a users tweets.
  }
  tag 'twitter:tweets:each' do |tag|
    tag.locals.tweets.collect do |tweet|
      tag.locals.tweet = tweet
      tag.expand
    end
  end


  desc %{
    Creates the context for a single tweet.
  }
  tag 'twitter:tweets:each:tweet' do |tag|
    tag.expand
  end

  desc %{
    Renders the text for the current tweet.
  }
  tag 'tweet:text' do |tag|
    tweet = tag.locals.tweet
    replace_links tweet.text
  end

  desc %{
    Renders the created_at timestamp for the current tweet.
  }
  tag 'tweet:created_at' do |tag|
    tweet = tag.locals.tweet
    tweet.created_at
  end

  desc %{
    Renders the created ago string for the tweet e.g. Created 7 days ago...
  }
  tag 'tweet:created_ago' do |tag|
    tweet = tag.locals.tweet
    time_ago_in_words tweet.created_at
  end

  desc %{
    Renders the source for the current tweet.
  }
  tag 'tweet:source' do |tag|
    tweet = tag.locals.tweet
    tweet.source
  end

  private
    def twitter_status(max = 1)
      begin
        max = 1 if (max>10) or (max< 1)
        client = twitter_login
        client.user_timeline[0..(max-1)]
      rescue Exception => e
        # Twitter failed... just log for now
        logger.error "Twitter Notification failure: #{e.inspect}"
      end
    end

  def twitter_login
    begin
      httpauth = Twitter::HTTPAuth.new(config['twitter.username'], config['twitter.password'])
      client = Twitter::Base.new(httpauth)
      return client
    rescue Exception => e
      logger.error "Twitter Notification failure: #{e.inspect}"
    end
  end

  def replace_links(text)
    text.gsub(/(http:\/\/[^\s]*)/, '<a class="twitter_link" href="\1">\1</a>')
  end
end
