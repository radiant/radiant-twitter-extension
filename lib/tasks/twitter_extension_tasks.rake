namespace :radiant do
  namespace :extensions do
    namespace :twitter do
      
      desc "Runs the migration of the Twitter extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          TwitterExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          TwitterExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Twitter to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from TwitterExtension"
        Dir[TwitterExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(TwitterExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
