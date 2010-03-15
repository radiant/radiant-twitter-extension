# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'
class TwitterExtension < Radiant::Extension
  version "1.1"
  description "Posts notification of pages to Twitter."
  url "http://github.com/seancribbs/radiant-twitter-extension"

  define_routes do |map|
    map.with_options :controller => 'twitter' do |t|
      t.twitter '/admin/twitter', :action => "edit"
    end
  end
  
  def activate
    unless admin.respond_to?(:settings)
#      admin.tabs.add "Twitter", "/admin/twitter"
       tab "Content" do
         add_item( "Twitter", "/admin/twitter")
       end
    end
    admin.pages.edit.add :extended_metadata, "twitter"
    Page.class_eval { include TwitterNotification, TwitterTags }
    
    if admin.respond_to?(:help)
      admin.help.index.add :page_details, 'twitter'
    end
  end
end