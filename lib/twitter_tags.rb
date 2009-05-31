require 'twitter'
module TwitterTags
  include ActionView::Helpers::DateHelper
  include Radiant::Taggable

  tag 'twitter' do |tag|
    tag.expand
  end
  
  desc %{
    Usage:
    <pre><code><r:twitter:message /></code></pre>
    Displays the latest status message from the current user's timeline }
  tag 'twitter:message' do |tag|
    status = twitter_status
    text = status.text.gsub(/(http:\/\/[^\s]*)/, '<a class="twitter_link" href="\1">\1</a>')
    "<a class=\"twitter_user\" href=\"http://twitter.com/#{status.user.screen_name}\">#{status.user.screen_name}</a> #{text} <p class=\"twitter_time\">#{time_ago_in_words(status.created_at)} ago from #{status.source}</p>"
  end
  
  private
    def twitter_status
      begin
        httpauth = Twitter::HTTPAuth.new(config['twitter.username'], config['twitter.password'])
        client = Twitter::Base.new(httpauth)
        return client.user_timeline[0]
      rescue Exception => e
        # Twitter failed... just log for now
        logger.error "Twitter Notification failure: #{e.inspect}"
      end
    end
end