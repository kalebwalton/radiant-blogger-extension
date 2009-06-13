$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'time'
require File.dirname(__FILE__) + '/../lib/blogger_reader'

# This is just crap test code - don't try running it...
b = BloggerReader.new("kalebwalton2.blogspot.com")
posts = b.posts({
  :published_after => Time.parse("6/11/2009"),
  :published_before => Time.parse("6/13/2009"),
  :categories => ['yes']
})
posts.each do |post|
  puts "TITLE: "+post[:title]
  puts "COMMENTS: "+post[:comment_count].to_s
  comments = b.comments(post[:id])
  unless comments.empty?
    comments.each do |comment|
      puts comment[:title]
      puts "CONTENT: "+comment[:content]
      puts comment[:author][:name]
      puts comment[:author][:uri]
    end
  end
end
