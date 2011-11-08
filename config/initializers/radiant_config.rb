Radiant.config do |config|
  config.namespace 'twitter' do |twit|
    twit.define 'username', :default => '', :allow_blank => true
    twit.define 'password', :default => '', :allow_blank => true
    twit.define 'token', :default => '', :allow_blank => true
    twit.define 'secret', :default => '', :allow_blank => true
    twit.define 'include_rts?', :default => true
  end
end
