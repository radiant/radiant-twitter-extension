require 'twitter'
module TwitterNotification
  def self.included(base)
    base.class_eval {
      after_save :notify_twitter
    }
  end
  
  def notify_twitter
    if published? && twitter_configured? && parent.notify_twitter_of_children? && !self.twitter_id
      title_length = 160 - absolute_url.length - 2
      message_title = title.length > title_length ? (title[0..title_length-4] + "...") : title
      message = "#{message_title}: #{absolute_url}"
      begin
        status = Twitter::Base.new(config['twitter.username'], config['twitter.password']).update(message, :source => "Radiant Twitter Notifier")
        # Don't trigger save callbacks
        self.class.update_all(:twitter_id => status.id, :id => self.id)
      rescue Exception => e
        # Twitter failed... just log for now
        logger.error "Twitter Notification failure: #{e.inspect}"
      end
    end
  end

  def absolute_url
    if config['twitter.url_host'] =~ /^http/
      "#{config['twitter.url_host']}#{self.url}"
    else
      "http://#{config['twitter.url_host']}#{self.url}"
    end
  end

  def twitter_configured?
    !%w(twitter.username twitter.password twitter.url_host).any? {|k| config[k].blank? }
  end

  def config
    Radiant::Config
  end
end