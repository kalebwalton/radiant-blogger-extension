require 'net/https'
require 'uri'
require 'builder'
require 'rexml/document'
require 'cgi'
require 'time'

class BloggerReader
  # Creates a new instance of the Client class, which prepares the connection
  # to the service.
  def initialize(blog_url)
    @http = Net::HTTP.new(blog_url)
  end

  # Sends an HTTP GET request to the url specified in the instantiation of
  # the class.
  def http_get(path)
    response, data = @http.get(path)
  end
  
  # Retrieves the post feed from the blog contained in @blog_id.  Run through
  # REXML, it returns an array of the different id's of that blog's posts.
  # Accepts the following options
  #   :published_after - Time
  #   :published_before - Time
  #   :categories - Array of Strings
  #   :max_results - Integer
  #   :start_index - Integer
  def posts(options = {})
    categories = options[:categories]
    
    params = []
    params << "published-min=#{options[:published_after].xmlschema}" unless options[:published_after].nil?
    params << "published-max=#{options[:published_before].xmlschema}" unless options[:published_before].nil?
    params << "max-results=#{options[:max_results]}" unless options[:max_results].nil?
    params << "start-index=#{options[:start_index]}" unless options[:start_index].nil?
    params
    
    url = "/feeds/posts/default"
    url += "/-/#{categories.join('/')}" unless categories.nil? || categories.empty?
    url += "?#{params.join("&")}" unless params.empty?

    posts_feed = http_get(url)
    posts = []
    REXML::Document.new(posts_feed[1]).elements.each('feed/entry') do |entry|
      posts << parse_post(entry)
    end
    posts
  end
  
  def post(post_id)
    post_entry_feed = http_get("/feeds/posts/default/#{post_id}")
    post_entry = {}
    REXML::Document.new(post_entry_feed[1]).elements.each('entry') do |entry|
      post_entry = parse_post(entry)
    end
    post_entry
  end

  def comments(post_id)
    comments_feed = http_get("/feeds/#{post_id}/comments/default")
    comments = []
    REXML::Document.new(comments_feed[1]).elements.each('feed/entry') do |entry|
      comments << parse_comment(entry)
    end
    comments
  end

  def parse_post(entry)
    post = {}
    post[:id] = entry.elements['id'].get_text.to_s.split(/post-/).last
    post[:title] = entry.elements['title'].get_text.to_s
    post[:published_on] = Time.parse(entry.elements['published'].get_text.to_s)
    post[:updated_on] = Time.parse(entry.elements['updated'].get_text.to_s)
    post[:author] = {}
    post[:author][:name] = entry.elements['author'].elements['name'].get_text.to_s
    post[:author][:uri] = entry.elements['author'].elements['uri'].get_text.to_s  
    post[:author][:email] = entry.elements['author'].elements['email'].get_text.to_s
    entry.elements.each('link') do |link|
      rel = link.attribute('rel').value
      type = link.attribute('type').value
      if rel == 'replies' and type == 'text/html'
        post[:post_comment_link] = link.attribute('href').value
        post[:comment_count] = link.attribute('title').value.split(' ')[0].to_i
      end
      if rel == 'alternate' and type == 'text/html'
        post[:link] = link.attribute('href').value
      end
    end
    post[:content] = CGI.unescapeHTML(entry.elements['content'].get_text.to_s)
    post
  end

  def parse_comment(entry)
    comment = {}
    comment[:title] = entry.elements['title'].get_text.to_s
    comment[:published_on] = Time.parse(entry.elements['published'].get_text.to_s)
    comment[:updated_on] = Time.parse(entry.elements['updated'].get_text.to_s)
    comment[:content] = CGI.unescapeHTML(entry.elements['content'].get_text.to_s)
    comment[:author] = {}
    comment[:author][:name] = entry.elements['author'].elements['name'].get_text.to_s
    comment[:author][:uri] = entry.elements['author'].elements['uri'].get_text.to_s  
    comment[:author][:email] = entry.elements['author'].elements['email'].get_text.to_s
    comment
  end
  
end
