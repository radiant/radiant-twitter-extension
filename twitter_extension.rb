class TwitterExtension < Radiant::Extension
  version "1.2"
  description "Posts notification of pages to Twitter and displays"
  url "http://github.com/ehaselwanter/radiant-twitter-extension"

  define_routes do |map|
    map.with_options :controller => 'twitter' do |t|
      t.twitter '/admin/twitter', :action => "edit"
    end
  end

  extension_config do |config|
    config.gem "addressable", :version => '~> 2.0.1', :lib => false
    config.gem "do_sqlite3", :version => '0.9.11'
    config.gem "dm-core", :version => '0.9.10'
    config.gem 'api_cache', :source => 'http://gemcutter.org'
    config.gem 'moneta', :source => 'http://gemcutter.org'
  end
  
  def activate
    unless admin.respond_to?(:settings)
       tab "Content" do
         add_item( "Twitter", "/admin/twitter")
       end
    end
    admin.pages.edit.add :extended_metadata, "twitter"
    Page.class_eval { include TwitterNotification, TwitterTags }

    require 'api_cache'
    require "dm-core" 
    require 'moneta'
#    require 'moneta/file'
#    require 'moneta/memory' 

    require "moneta/datamapper"

#    APICache.store = Moneta::File.new(:path => File.join(RAILS_ROOT,"tmp", "moneta_file_cache"))
#    APICache.store = Moneta::Memory.new
     APICache.store = Moneta::DataMapper.new(:setup => "sqlite3://#{File.join(RAILS_ROOT,"tmp", "moneta_datamapper_cache.db")}")
    
    if admin.respond_to?(:help)
      admin.help.index.add :page_details, 'twitter'
    end
  end
end