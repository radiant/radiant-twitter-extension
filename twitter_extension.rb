# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'
class TwitterExtension < Radiant::Extension
  version "1.0"
  description "Posts notification of pages to Twitter."
  url "http://github.com/seancribbs/radiant-twitter-extension"

  define_routes do |map|
    map.connect '/admin/twitter', :controller => "twitter", :action => "edit", :method => :get
    map.connect '/admin/twitter', :controller => "twitter", :action => "update", :method => :put
  end
  
  def activate
    admin.tabs.add "Twitter", "/admin/twitter", :after => "Layouts", :visibility => [:all]
    admin.page.edit.add :extended_metadata, "twitter"
    Page.class_eval { include TwitterNotification }
  end
end