require 'radiant-twitter-extension'

class TwitterExtension < Radiant::Extension
  version RadiantTwitterExtension::VERSION
  description RadiantTwitterExtension::DESCRIPTION
  url RadiantTwitterExtension::URL
  
  def activate
    Page.send :include, TwitterNotification             # tweet page title upon publication
    Page.send :include, TwitterTags                     # radius tags to display twitter search results
    
    admin.pages.edit.add :extended_metadata, "twitter"  # toggle twitter-posting at parent level
    admin.configuration.show.add :config, 'admin/configuration/twitter_show', :after => 'defaults'
    admin.configuration.edit.add :form,   'admin/configuration/twitter_edit', :after => 'edit_defaults' 
  end
end
