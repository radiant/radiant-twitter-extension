require 'twitter'
module TwitterNotification
  def self.included(base)
    base.class_eval {
      after_save :notify_twitter
    }
  end
  
  def notify_twitter
    if parent
      if published? && twitter_configured? && parent.notify_twitter_of_children? && !self.twitter_id
        title_length = 138 - absolute_url.length
        message_title = title.length > title_length ? (title[0..title_length-4] + "...") : title
        message = "#{message_title}: #{absolute_url}"
        begin
          httpauth = Twitter::HTTPAuth.new(twitter_config['twitter.username'], twitter_config['twitter.password'])
          client = Twitter::Base.new(httpauth)
          status = client.update(message, :source => "radianttwitternotifier")
          # Don't trigger save callbacks
          self.class.update_all({:twitter_id => client.id}, :id => self.id)
        rescue Exception => e
          # Twitter failed... just log for now
          logger.error "Twitter Notification failure: #{e.inspect}"
        end
      end
    end
  end

  def absolute_url
    if twitter_config['twitter.url_host'] =~ /^http/
      "#{config['twitter.url_host']}#{self.url}"
    else
      "http://#{config['twitter.url_host']}#{self.url}"
    end
  end

  def twitter_configured?
    !%w(twitter.username twitter.password twitter.url_host).any? {|k| twitter_config[k].blank? }
  end

  def twitter_config
    Radiant::Config
  end
end