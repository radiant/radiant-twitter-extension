require 'twitter'

module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable
  class TagError < StandardError; end

  tag 'twitter' do |tag|
    tag.expand
  end

  desc %{
    Retrieve a list of tweets. The minimal default is to return the ten most recent tweets of the 
    Radiant.configured twitter user (that is, the person as whom radiant is set up to tweet).
    For that, you can use just a single tag:
    
    <pre><code><r:twitter:tweets /></code></pre>
    
    or control the presentation of tweets in a more detailed way:
    
    <r:twitter:tweets:each><r:tweet:user:screen_name /> : <r:tweet:text /></r:twitter:tweets:each>
    
    You can also specify a search in various ways. 
    
    * Supply a `max` attribute to change the number of tweets displayed. Default is 10.
    * Supply a `user` attribute to display tweets from a different username
    * Supply a `list` attribute to display tweets from the named list (see also r:twitter:list for a shortcut)
    * Supply a `search` attribute to show tweets containing that text (see also r:twitter:search for a shortcut)
      You don't need to %escape the search string. 
      In a search query the user and list parameters will be ignored.
    
    <pre><code>
      <r:twitter:tweets user="spanner_org" max="2" />
      <r:twitter:tweets search="#radiant" />
    </code></pre>
    
  }
  tag 'twitter:tweets' do |tag|  
    tag.locals.tweets = fetch_and_cache_tweets(tag.attr.slice('user', 'max', 'search', 'list').symbolize_keys)
    tag.double? ? tag.expand : tag.render('twitter:messages')
  end
  
  tag 'twitter:tweets:each' do |tag|
    tag.locals.tweets ||= fetch_and_cache_tweets(tag.attr.slice('user', 'max', 'search', 'list').symbolize_keys)
    tag.render('_tweets_list', tag.attr.dup, &tag.block)
  end

  desc %{
    Fetches and loops through tweets matching the supplied search string. You don't need to %escape the search string.

    <pre><code>
      <r:twitter:search for="#radiant"><r:tweets:each>...</r:tweets:each></r:twitter:search>
      <r:twitter:search for="rails cms" max="1">...</r:twitter:search>
      <r:twitter:search for="somethinbg" max="20">...</r:twitter:search>
    </code></pre>
    
    Short form also works:
    
    <pre><code><r:twitter:search for="#radiant" /></code></pre>

    and you can go stright into a loop:
    
    <pre><code><r:twitter:search:each for="#radiant">...</r:twitter:search:each></code></pre>    
  }
  tag 'twitter:search' do |tag|
    tag.locals.tweets = fetch_and_cache_tweets(:search => tag.attr['for']) if tag.attr.any?
    tag.double? ? tag.expand : tag.render('twitter:messages')
  end

  tag 'twitter:search:each' do |tag|
    tag.locals.tweets ||= fetch_and_cache_tweets(:search => tag.attr['for'])
    tag.render('_tweets_list', tag.attr.dup, &tag.block)
  end

  desc %{
    Fetches tweets from the specified list belonging to the specified (or default) user.

    <pre><code><r:twitter:list list="listname" [user="username"] [max="10"]  /></code></pre>
    
    Short form also works:
    
    <pre><code><r:twitter:list list="radiant" /></code></pre>
    
    and you can go stright into a loop:
    
    <pre><code><r:twitter:list:each list="radiant">...</r:twitter:list:each></code></pre>    
  }
  tag 'twitter:list' do |tag|
    tag.locals.tweets = fetch_and_cache_tweets(:user => tag.attr['user'], :max => tag.attr['max'], :list => tag.attr['list']) if tag.attr.any?
    tag.double? ? tag.expand : tag.render('twitter:messages')
  end
  
  tag 'twitter:list:each' do |tag|
    tag.locals.tweets ||= fetch_and_cache_tweets(:user => tag.attr['user'], :max => tag.attr['max'], :list => tag.attr['list'])
    tag.render('_tweets_list', tag.attr.dup, &tag.block)
  end

  desc %{
    Returns the number of tweets.
  }
  tag 'tweets:length' do |tag|
    tag.render('_tweets_length', tag.attr.dup, &tag.block)
  end

  desc %{
    Loops through the current list of tweets.
  }
  tag 'tweets:each' do |tag|
    tag.render('_tweets_list', tag.attr.dup, &tag.block)
  end

  # these are just for drying out: they can't be called directly.

  tag '_tweets_list' do |tag|
    raise TagError, "tweet_list utility tag called without a list of tweets to list" unless tag.locals.tweets
    out = ""
    tag.locals.tweets.each do |tweet|
      tag.locals.tweet = tweet
      if tag.double? 
        out << tag.expand
      else 
        out << tag.render('tweet:message')
      end
    end
    out
  end
  
  tag '_tweets_length' do |tag|
    raise TagError, "_tweets_length utility tag called without a list of tweets to length" unless tag.locals.tweets
    tag.locals.tweets.length
  end

  desc %{
    Usage:

    This is a shortcut that displays messages from a twitter user's timeline. 
    The username can be specified with a 'user' parameter, or we will default to the Radiant.configured twitter user.
    The number of messages is determined by the 'max' parameter, which must be 10 or less. Default is 5.

    <pre><code><r:twitter:messages max="10" /></code></pre>
  }
  tag 'twitter:messages' do |tag|
    out = ""
    tag.locals.tweets ||= fetch_and_cache_tweets(:user => tag.attr['user'], :max => tag.attr['max'])
    tag.locals.tweets.each do |tweet|
      tag.locals.tweet = tweet
      out << tag.render('tweet:message')
    end
    out
  end
  
  deprecated_tag 'twitter:message', :substitute => 'twitter:messages'

  tag 'tweet' do |tag|
    tag.expand if tag.locals.tweet
  end
  
  desc %{
    Shortcut to display a single tweet in the standard way suggested by https://dev.twitter.com/terms/display-guidelines.
    
    Note that for this to work you will probably want to include the twitter intents javascript in your page, and you may
    also want to include the supplied `twitter.sass` in your site stylesheets.
  }
  tag 'tweet:message' do |tag|
    if tweet = tag.locals.tweet
      text = replace_links(tweet.text)
      screen_name = tweet.from_user || tweet.user.screen_name   # search returns a different data structure
      date = tag.render('tweet:date', tag.attr.dup.merge('format' => "%d %B"))
      %{
        <p class="twitter">
          <a class="twitter_avatar" href="http://twitter.com/#{screen_name}">#{tag.render("tweet:avatar")}</a> 
          <span class="tweet">
            <a class="twitter_user" href="http://twitter.com/#{screen_name}">#{screen_name}</a> 
            <span class="twitter_name">#{tag.render('tweet:user:name')}</span>
            <span class="twitter_text">#{text}</span>
            <span class="twitter_links">
              #{tag.render('tweet:permalink')}
              #{tag.render('tweet:reply_link')}
              #{tag.render('tweet:retweet_link')}
              #{tag.render('tweet:favorite_link')}
            </span>
          </span>
        </p>
      }
    end
  end

  [:coordinates, :in_reply_to_screen_name, :truncated, :in_reply_to_user_id, :in_reply_to_status_id, 
    :source, :place, :geo, :favorited, :contributors, :id].each do |method|
    desc %{
      Renders the @#{method.to_s}@ attribute of the tweet
      <pre><code><r:tweet:#{method.to_s}/></code></pre>
    }
    tag "tweet:#{method.to_s}" do |tag|
      
      p "calling #{method} of #{tag.locals.tweet.inspect}"
      p "respond_to?(:source) is #{tag.locals.tweet.respond_to?(:source).inspect} and source is #{tag.locals.tweet.source}"
      
      tag.locals.tweet.send(method) if tag.locals.tweet.respond_to? method
    end

    desc %{
      expands if the property has a value
      <pre><code><r:tweet:if_#{method.to_s}/></code></pre>
    }
    tag "tweet:if_#{method.to_s}" do |tag|
      value = tag.locals.tweet.send(method) if tag.locals.tweet.respond_to? method
      tag.expand if !value.nil? && !value.empty?
    end

    desc %{
      expands if the property has no value
      <pre><code><r:tweet:unless_#{method.to_s}/></code></pre>
    }
    tag "tweet:unless_#{method.to_s}" do |tag|
      value = tag.locals.tweet.send(method) if tag.locals.tweet.respond_to? method
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
      I18n.l date, :format => format
    end
  end

  tag 'tweet:user' do |tag|
    unless tag.locals.twitterer = tag.locals.tweet.user
      tag.locals.twitterer = fetch_twitter_user(tag.locals.tweet.from_user)
    end
    raise TagError, "twitter user could not be found" unless tag.locals.twitterer
    tag.expand
  end

  [:time_zone, :description, :lang, :profile_link_color, :profile_background_image_url, :profile_sidebar_fill_color, :following, 
    :profile_background_tile, :created_at, :statuses_count,:profile_sidebar_border_color,:profile_use_background_image,:followers_count,
    :contributors_enabled,:notifications,:friends_count,:protected,:url,:profile_image_url,:geo_enabled,:profile_background_color,
    :name,:favourites_count,:location,:screen_name, :id,:verified,:utc_offset,:profile_text_color].each do |method|
    desc %{
      Renders the @#{method.to_s}@ attribute of the tweeting user
      <pre><code><r:tweet:user:#{method.to_s}/></code></pre>
    }
    tag "tweet:user:#{method.to_s}" do |tag|
      tag.locals.twitterer.send(method)
    end

    desc %{
      expands if @#{method.to_s}@ attribute of the tweeting user has a value
      <pre><code><r:tweet:user:if_#{method.to_s}/></code></pre>
    }
    tag "tweet:user:if_#{method.to_s}" do |tag|
      value = tag.locals.twitterer.send(method) rescue nil
      tag.expand unless value.nil? || value.empty?
    end

    desc %{
      expands if @#{method.to_s}@ attribute of the tweeting user has no value
      <pre><code><r:tweet:user:unless_#{method.to_s}/></code></pre>
    }
    tag "tweet:user:unless_#{method.to_s}" do |tag|
      value = tag.locals.twitterer.send(method) rescue nil
      tag.expand if value.nil? || value.empty?
    end
  end
  
  desc %{
    Renders an avatar image for the tweeter of the current tweet.
  }
  tag 'tweet:avatar' do |tag|
    url = tag.locals.tweet.profile_image_url || tag.render('tweet:user:profile_image_url')
    %{<img src="#{url}" class="twitter_avatar" />}
  end

  desc %{
    Renders the text for the current tweet.
  }
  tag 'tweet:text' do |tag|
    tweet = tag.locals.tweet
    replace_links(tweet.text)
  end

  desc %{
    Renders the created ago string for the tweet e.g. Created 7 days...
  }
  tag 'tweet:created_ago' do |tag|
    tweet = tag.locals.tweet
    time_ago_in_words tweet.created_at
  end

  desc %{
    Renders a permalink to this tweet with its date as the default link text.
  }
  tag 'tweet:permalink' do |tag|
    cssclass = tag.attr['class'] || 'twitter_permalink'
    text = tag.double? ? tag.expand : I18n.l(tag.locals.tweet.created_at, :twitter)
    %{<a class="#{cssclass}" href="http://twitter.com/#!/#{screen_name}/status/#{tweet.id_str}">#{text}</a>}
  end

  desc %{
    Renders a 'Reply' link that can be left as it is or hooked up by the twitter javascript.
  }
  tag 'tweet:reply_link' do |tag|
    cssclass = tag.attr['class'] || 'twitter_reply'
    text = tag.double? ? tag.expand : I18n.t('twitter_extension.reply')
    %{<a class="#{cssclass}" href="http://twitter.com/intent/tweet?in_reply_to=#{tag.locals.tweet.id_str}">#{text}</a>}
  end

  desc %{
    Renders a 'Retweet' link that can be left as it is or hooked up by the twitter javascript.
  }
  tag 'tweet:retweet_link' do |tag|
    cssclass = tag.attr['class'] || 'twitter_retweet'
    text = tag.double? ? tag.expand : I18n.t('twitter_extension.retweet')
    %{<a class="#{cssclass}" href="http://twitter.com/intent/retweet?tweet_id=#{tag.locals.tweet.id_str}">#{text}</a>}
  end

  desc %{
    Renders a 'Favorite' link that can be left as it is or hooked up by the twitter javascript.
  }
  tag 'tweet:favorite_link' do |tag|
    cssclass = tag.attr['class'] || 'twitter_favorite'
    text = tag.double? ? tag.expand : I18n.t('twitter_extension.favorite')
    %{<a class="#{cssclass}" href="http://twitter.com/intent/favorite?tweet_id=#{tag.locals.tweet.id_str}">#{text}</a>}
  end

private

  # Retained for compatibility
  #
  def twitter_status(max = 1)
    max = 1 if (max > 10) or (max < 1)
    fetch_and_cache_tweets(:max => max)
  end
  
  # General-purpose tweet-fetcher using Rails::Cache to provide a calm-enhancing gap between similar
  # requests. Set Radiant.config['twitter.expires_in'] to change the gap from 5 minutes.
  # Always returns an array of tweet hashes (mashes, really).
  # :max, :user, :list and :search options are used to determine the call we make (and the cache key).
  # :page and :per_page options are passed through to the search call but not the user or list calls.
  # other options are passed through (to non-search calls) unchanged.
  #
  def fetch_and_cache_tweets(options = {})
    max = options.delete(:max) || 10
    user = options.delete(:username) || Radiant.config['twitter.username']
    list = options.delete(:list) || Radiant.config['twitter.listname']
    search = options.delete(:search)
    options[:count] ||= max
    cache_key = ['twitter', list, user, max, search].compact.join('_')
    begin
      tweets = Rails.cache.fetch(cache_key,:expires_in => twitter_cache_duration) do
        if search
          Twitter::Search.new.containing(search).page(options[:page] || 1).per_page(options[:per_page] || 10).fetch
        elsif list
          twitter_client.list_timeline(user, list, options)
        else
          twitter_client.user_timeline(user, options)
        end
      end
      
    rescue Twitter::Error => e
      logger.error "Unable to fetch timeline: #{e.inspect}"
    end

    tweets || []
  end
  
  def fetch_twitter_user(screen_name)
    cache_key = "twitter_user_#{screen_name}"
    begin
      twitter_user = Rails.cache.fetch(cache_key,:expires_in => twitter_cache_duration) do
        twitter_client.user(screen_name)
      end
    rescue Twitter::Error => e
      logger.error "Unable to fetch user '#{screen_name}': #{e.inspect}"
    end
  end

  # these operations don't require authentication
  #
  def twitter_client
    @twitter_client ||= Twitter::Client.new
  end

  # Turns http
  #
  def replace_links(text)
    text = text.gsub(/(https?:\/\/\S*)/, '<a class="twitter_link" href="\1">\1</a>')
    text = text.gsub(/@(\w*)/, '@<a class="twitter_link" href="http://twitter.com/\1">\1</a>')
    text = text.gsub(/#(\w*)/, '<a class="twitter_link" href="http://twitter.com/search/#\1">#\1</a>')
  end

  # The interval between twitter api calls with the same parameters is set by the
  # `twitter.expires_in` config entry and defaults to 5 minutes.
  #
  def twitter_cache_duration
    @twitter_expires_in ||= (Radiant::Config["twitter.expires_in"] || 5).to_i.minutes
  end
end
