class AddTwitterNotificationFields < ActiveRecord::Migration
  def self.up
    add_column :pages, :notify_twitter_of_children, :boolean, :default => false
    add_column :pages, :twitter_id, :string
  end
  
  def self.down
    remove_column :pages, :notify_twitter_of_children
    remove_column :pages, :twitter_id
  end
end