require 'twitter'
require 'hashie'

module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  desc %{
    Usage:
    <pre><code><r:twitter:message [max="10"] /></code></pre>
    Displays the latest status message from the current user's timeline. If you require finer grained control please use the individual tags like:

  <pre><code>
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
  </r:twitter>
  </code></pre>
  }
  tag 'twitter:message' do |tag|
    max=tag.attr['max'].to_i
    out = ""
    twitter_status(max).each do |status|
      text = replace_links status.text
      out << "<p class=\"twitter_tweet\"><a class=\"twitter_user\" href=\"http://twitter.com/#{status.user.screen_name}\">#{status.user.screen_name}</a> #{text} <span class=\"twitter_time\">#{time_ago_in_words(status.created_at)} ago from #{status.source}</span></p>\n"
    end
    out
  end

  desc %{
    Context for the twitter tags. <br />
    The user account defined in the Radiant config keys "twitter.password", "twitter.username" and "site.host" will be accessed.

    Displays the tweets from the current user's timeline:
  <pre><code>
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
  </r:twitter>
  </code></pre>


  <br/>
  You can simply just use <pre><code><r:twitter:message  [max="10"] /></code></pre> if you don't require fine grained control over structure/styling.

  }
  tag 'twitter' do |tag|
    tag.locals.client = twitter_login
    tag.expand
  end

  desc %{
    Retrieve a users recent tweets, optional max, default 10. Usage:
    <pre><code><r:twitter:tweets  [max="10"]  [user="username"]/></code></pre>
  }
  tag 'twitter:tweets' do |tag|  
    tag.locals.max = tag.attr['max'].blank? ? 3 : tag.attr['max'].to_i - 1
    tag.locals.user = tag.attr['user'].blank? ? config['twitter.username'] : tag.attr['user']
    tag.locals.tweets = JSON.parse(Rails.cache.fetch("timeline_#{tag.locals.user}_#{tag.locals.max}",:expires_in => twitter_expires_in ) do
      result = {}
      begin
        result = Twitter.user_timeline(tag.locals.user, {:page => 1, :per_page => tag.locals.max} )[0..(tag.locals.max)].to_json
      rescue Exception => e
        logger.error "Unable to fetch user timeline: #{e.inspect}"
        result = {}
      end
      result
    end).map{|hash| Hashie::Mash.new(hash)}
    out = ""
    if tag.locals.tweets
      tag.expand
    else
      out << "Unable to fetch user timeline. Please check the logs.."
      return out
    end
  end

  desc %{
    Retrieve a users recent list, optional max, default 10. Usage:
    <pre><code><r:twitter:list list="mylist" [user="username"] [max="10"]  /></code></pre>
  }
  tag 'twitter:list' do |tag|
    tag.locals.max = tag.attr['max'].blank? ? 3 : tag.attr['max'].to_i - 1
    tag.locals.user = tag.attr['user'].blank? ? config['twitter.username'] : tag.attr['user']
    tag.locals.tweets = JSON.parse(Rails.cache.fetch("list_timeline_#{tag.locals.user}_#{tag.attr['list']}_#{tag.locals.max}",:expire_in => twitter_expires_in  ) do
      result = {}
      begin
        result = Twitter.list_timeline(tag.locals.user,tag.attr['list'], {:page => 1, :per_page => tag.locals.max} ).to_json
      rescue Exception => e
        logger.error "Unable to fetch user list: #{e.inspect}"
        result = {}
      end
      result
    end).map{|hash| Hashie::Mash.new(hash)}
    out = ""
    if tag.locals.tweets
      tag.expand
    else
      out << "Unable to fetch user list. Please check the logs.."
      return out
    end
  end

  desc %{
    Returns the number of tweets.
  }
  tag 'twitter:list:length' do |tag|
    tag.locals.tweets.length
  end

  desc %{
    Loops through a users tweets.
  }
  tag 'twitter:list:each' do |tag|
    tag.locals.tweets.collect do |tweet|
      tag.locals.tweet = tweet
      tag.expand
    end
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
    Creates the context for a single tweet.
  }
  tag 'twitter:list:each:tweet' do |tag|
    tag.expand
  end

  desc %{
    Creates the context for a single tweet user.
  }
  tag 'twitter:list:each:tweet:user' do |tag|
    tag.expand
  end

    [:coordinates, :in_reply_to_screen_name, :truncated, :in_reply_to_user_id, :in_reply_to_status_id, :source, :place, :geo, :favorited, :contributors, :id].each do |method|
    desc %{
      Renders the @#{method.to_s}@ attribute of the tweet
    <pre><code><r:tweet:#{method.to_s}/></code></pre>

    }
    tag "tweet:#{method.to_s}" do |tag|
      tag.locals.tweet.send(method) rescue nil
    end
    end

      [:coordinates, :in_reply_to_screen_name, :truncated, :in_reply_to_user_id, :in_reply_to_status_id, :source, :place, :geo, :favorited, :contributors, :id].each do |method|
    desc %{
      expands if the property has a value
    <pre><code><r:tweet:if_#{method.to_s}/></code></pre>

    }
    tag "tweet:if_#{method.to_s}" do |tag|
      value = tag.locals.tweet.send(method) rescue nil
      tag.expand if !value.nil? && !value.empty?
    end
      end

  [:coordinates, :in_reply_to_screen_name, :truncated, :in_reply_to_user_id, :in_reply_to_status_id, :source, :place, :geo, :favorited, :contributors, :id].each do |method|
    desc %{
      expands if the property has no value
    <pre><code><r:tweet:unless_#{method.to_s}/></code></pre>

    }
    tag "tweet:unless_#{method.to_s}" do |tag|
      value = tag.locals.tweet.send(method) rescue nil
      tag.expand if value.nil? || value.empty?
    end
  end

  [:date, :created_at].each do |method|
    desc %{
      renders the  created_at timestamp of the tweet
    <pre><code><r:tweet:#{method.to_s} [format="%c"]/></code></pre>

    }
    tag "tweet:#{method.to_s}" do |tag|
      format = tag.attr['format'] || "%c"
      date = DateTime.parse(tag.locals.tweet.created_at)
      I18n.l date , :format => format
    end
  end

    user_params = [:time_zone, :description, :lang, :profile_link_color, :profile_background_image_url, :profile_sidebar_fill_color, :following, :profile_background_tile, :created_at, :statuses_count,:profile_sidebar_border_color,:profile_use_background_image,:followers_count,:contributors_enabled,:notifications,:friends_count,:protected,:url,:profile_image_url,:geo_enabled,:profile_background_color,:name,:favourites_count,:location,:screen_name, :id,:verified,:utc_offset,:profile_text_color]
    user_params.each do |method|
      desc %{
        Renders the @#{method.to_s}@ attribute of the tweet user
        <pre><code><r:tweet:user:#{method.to_s}/></code></pre>
      }
      tag "tweet:user:#{method.to_s}" do |tag|
        tag.locals.tweet.user.send(method) rescue nil
      end

      desc %{
        expands if @#{method.to_s}@ attribute of the tweet user has a value
        <pre><code><r:tweet:user:if_#{method.to_s}/></code></pre>
      }
      tag "tweet:user:if_#{method.to_s}" do |tag|
        value = tag.locals.tweet.user.send(method) rescue nil
        tag.expand if !value.nil? && !value.empty?
      end

      desc %{
        expands if @#{method.to_s}@ attribute of the tweet user has no value
        <pre><code><r:tweet:user:unless_#{method.to_s}/></code></pre>
      }
      tag "tweet:user:unless_#{method.to_s}" do |tag|
        value = tag.locals.tweet.user.send(method) rescue nil
        tag.expand if value.nil? || value.empty?
      end
    end

  desc %{
    Renders the text for the current tweet.
  }
  tag 'tweet:text' do |tag|
    tweet = tag.locals.tweet
    replace_links tweet.text
  end

  desc %{
    Renders the created ago string for the tweet e.g. Created 7 days...
  }
  tag 'tweet:created_ago' do |tag|
    tweet = tag.locals.tweet
    time_ago_in_words tweet.created_at
  end

private

   def twitter_status(max = 1)
      begin
        max = 1 if (max > 10) or (max < 1)
        client = twitter_login
        client.user_timeline[0..(max-1)]
      rescue Exception => e
        # Twitter failed... just log for now
        logger.error "Twitter Notification failure: #{e.inspect}"
      end
    end

  def twitter_login
    Twitter.configure do |config|
      config.consumer_key = config['twitter.token']
      config.consumer_secret = config['twitter.secret']
      config.oauth_token = config["twitter.#{config['twitter.username']}.atoken"]
      config.oauth_token_secret =  config["twitter.#{config['twitter.username']}.asecret"]
    end
    Twitter::Client.new
  rescue Exception => e
    logger.error "Twitter login failure: #{e.inspect}"
  end

  def replace_links(text)
    text = text.gsub(/(http:\/\/[^\s]*)/, '<a class="twitter_link" href="\1">\1</a>')
    text.gsub(/@(\w*)/, '<a class="twitter_link" href="http://twitter.com/\1">@\1</a>')
  end

  def twitter_expires_in
    @twitter_expires_in ||= (Radiant::Config["twitter.expires_in"] || 5).to_i.minutes
  end
end
