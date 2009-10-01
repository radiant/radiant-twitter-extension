require 'twitter'
module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  tag 'twitter' do |tag|
    tag.expand
  end
  
  desc %{
    Usage:
    <pre><code><r:twitter:message  [max="10"] /></code></pre>
    Displays the latest status message from the current user's timeline }
  tag 'twitter:message' do |tag|
    max=tag.attr['max'].to_i
    out = ""
    twitter_status(max).each do |status|
      text = status.text.gsub(/(http:\/\/[^\s]*)/, '<a class="twitter_link" href="\1">\1</a>')
      out << "<p class=\"twitter_tweet\"><a class=\"twitter_user\" href=\"http://twitter.com/#{status.user.screen_name}\">#{status.user.screen_name}</a> #{text} <span class=\"twitter_time\">#{time_ago_in_words(status.created_at)} ago from #{status.source}</span></p>\n"
    end
    out
  end
  
  private
    def twitter_status(max = 1)
      begin
        max = 1 if (max>10) or (max< 1)
        httpauth = Twitter::HTTPAuth.new(config['twitter.username'], config['twitter.password'])
        client = Twitter::Base.new(httpauth)
        return client.user_timeline[0..(max-1)]
      rescue Exception => e
        # Twitter failed... just log for now
        logger.error "Twitter Notification failure: #{e.inspect}"
      end
    end
end
