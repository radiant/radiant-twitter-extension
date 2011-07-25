require 'twitter'
module TwitterNotification
  def self.included(base)
    base.class_eval {
      after_save :notify_twitter
    }
  end
  
  def notify_twitter
    if parent
      if published? && Radiant.configured? && parent.notify_twitter_of_children? && !self.twitter_id
        title_length = 138 - absolute_url.length
        message_title = title.length > title_length ? (title[0..title_length-4] + "...") : title
        message = "#{message_title}: #{absolute_url}"
        begin
          httpauth = Twitter::HTTPAuth.new(Radiant.config['twitter.username'], Radiant.config['twitter.password'])
          client = Twitter::Base.new(httpauth)
          status = client.update(message, :source => "radianttwitternotifier")
          # Don't trigger save callbacks
          self.class.update_all({:twitter_id => status.id}, :id => self.id)
        rescue Twitter::Error => e
          logger.error "Twitter Notification failure: #{e.inspect}"
        end
      end
    end
    true
  end

  def absolute_url
    if host = Radiant.config['site.host']
      if host =~ /^http/
        "#{host}#{self.url}"
      else
        "http://#{host}#{self.url}"
      end
    end
  end

  def Radiant.configured?
    !%w(twitter.username twitter.password site.host).any? {|k| Radiant.config[k].blank? }
  end

end