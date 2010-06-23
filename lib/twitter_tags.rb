require 'twitter'
module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  desc %{
    Usage:
    <pre><code><r:twitter:message  [max="10"] /></code></pre>
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
    The user account defined in the Radiant config keys "twitter.password", "twitter.username" and "twitter.url_host" will be accessed.

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
    tag.locals.max = tag.attr['max'].blank? ? 9 : tag.attr['max'].to_i - 1
    tag.locals.user = tag.attr['user'].blank? ? twitter_config['twitter.username'] : tag.attr['user']

    begin
      tag.locals.tweets = Twitter.timeline(tag.locals.user, {:page => 1, :per_page => tag.locals.max} )
    rescue Exception => e
      logger.error "Unable to fetch user timeline: #{e.inspect}"
    end
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
    tag.locals.max = tag.attr['max'].blank? ? 9 : tag.attr['max'].to_i - 1
    tag.locals.user = tag.attr['user'].blank? ? twitter_config['twitter.username'] : tag.attr['user']
    begin
      tag.locals.tweets = Twitter.list_timeline(tag.locals.user,tag.attr['list'], {:page => 1, :per_page => tag.locals.max} )
    rescue Exception => e
      logger.error "Unable to fetch user list: #{e.inspect}"
    end
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
    tag "tweet:#{method.to_s}" do |tag|
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
    user_params = [:time_zone, :description, :lang, :profile_link_color, :profile_background_image_url, :profile_sidebar_fill_color, :following, :profile_background_tile, :created_at, :statuses_count,:profile_sidebar_border_color,:profile_use_background_image,:followers_count,:contributors_enabled,:notifications,:friends_count,:protected,:url,:profile_image_url,:geo_enabled,:profile_background_color,:name,:favourites_count,:location,:screen_name, :id,:verified,:utc_offset,:profile_text_color]
      user_params.each do |method|
    desc %{
      Renders the @#{method.to_s}@ attribute of the tweet user
    <pre><code><r:tweet:user:#{method.to_s}/></code></pre>
    }
    tag "tweet:user:#{method.to_s}" do |tag|
      tag.locals.tweet.user.send(method) rescue nil
    end
      end

        user_params.each do |method|
    desc %{
      expands if @#{method.to_s}@ attribute of the tweet user has a value
    <pre><code><r:tweet:user:if_#{method.to_s}/></code></pre>
    }
    tag "tweet:user:if_#{method.to_s}" do |tag|
      value = tag.locals.tweet.user.send(method) rescue nil
      tag.expand if !value.nil? && !value.empty?
    end
        end

          user_params.each do |method|
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
    Renders the created_at timestamp for the current tweet.
    <pre><code><r:tweet:user:created_at [format="%c"]/></code></pre>

  }
  tag 'tweet:created_at' do |tag|
    format = tag.attr['format'] || "%c"
    date = DateTime.parse(tag.locals.tweet.created_at)
    date.strftime(format)
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
      oauth = Twitter::OAuth.new(twitter_config['twitter.token'], twitter_config['twitter.secret'])
      oauth.authorize_from_access(twitter_config["twitter.#{twitter_config['twitter.username']}.atoken"], twitter_config["twitter.#{twitter_config['twitter.username']}.asecret"])
      client = Twitter::Base.new(oauth)

      return client
    rescue Exception => e
      logger.error "Twitter login failure: #{e.inspect}"
    end
  end

  def replace_links(text)
    text = text.gsub(/(http:\/\/[^\s]*)/, '<a class="twitter_link" href="\1">\1</a>')
    text.gsub(/@(\w*)/, '<a class="twitter_link" href="http://twitter.com/\1">@\1</a>')
  end
end
