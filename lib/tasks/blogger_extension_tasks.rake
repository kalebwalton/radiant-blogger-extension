namespace :radiant do
  namespace :extensions do
    namespace :blogger do
      
      desc "Runs the migration of the Blogger extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          BloggerExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          BloggerExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Blogger to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from BloggerExtension"
        Dir[BloggerExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(BloggerExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
