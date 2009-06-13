require 'blogger_reader'
module BloggerTags
  include Radiant::Taggable

  desc %{
    Causes the tags referring to a blog's attributes to refer to the specified blog.

    *Usage:*
    
    <pre><code><r:blog url="http://yourblog.blogspot.com">...</r:blog></code></pre>
  }
  tag 'blog' do |tag|
    url = tag.attr['url']
    raise StandardTags::TagError.new("'url' attribute of 'blog' tag must be set") if url.nil?
    url.gsub!(/http.?\:\/\//,'').gsub!(/\/.*/,'')
    
    tag.locals.blogger_reader = BloggerReader.new(url)
    tag.expand
  end

  desc %{
    Gives access to a blog's posts.

    *Usage:*
    
    <pre><code><r:posts>...</r:posts></code></pre>
  }
  tag 'blog:posts' do |tag|
    tag.expand
  end

  desc %{
    Cycles through each of the posts. Inside this tag all post attribute tags
    are mapped to the current child post.

    Defaults to a limit of 25 posts.

    *Usage:*
    
    <pre><code><r:posts:each [categories="category_a, category_b"] [limit="number"]>
     ...
    </r:posts:each>
    </code></pre>
  }
  tag 'blog:posts:each' do |tag|
    attr = tag.attr.symbolize_keys

    options = {}

    if attr[:limit] =~ /^\d{1,4}$/
      options[:limit] = attr[:limit].to_i
    else
      raise StandardTags::TagError.new("`limit' attribute of `each' tag must be a positive number between 1 and 4 digits")
    end
    options[:limit] ||= 25

    unless attr[:categories].nil?
      options[:categories] = attr[:categories].gsub("/\s/",'').split(',')
    end
    options[:categories] ||= []

    br = tag.locals.blogger_reader
    posts = br.posts({:max_results => options[:limit], :categories => options[:categories]})
    Rails.logger.debug("blogger: "+posts.length.to_s)

    result = []
    posts.each_with_index do |post, i|
      tag.locals.post = post
      tag.locals.first_post = i == 0
      tag.locals.last_post = i == posts.length - 1
      result << tag.expand
    end
    result
  end

  
  desc %{
    Post attribute tags inside of this tag refer to the current post. This enables
    you to leverage the namespacing so you can use <r:title/>, <r:content/>, etc. 

    *Usage:*
    
    <pre><code><r:posts:each>
      <r:post><r:title/>...</r:post>
    </r:posts:each>
    </code></pre>
  }
  tag 'blog:post' do |tag|
    tag.expand
  end

  desc %{
    Renders the main content of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:content/>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:content' do |tag|
    tag.locals.post[:content]
  end

  desc %{
    Renders the title of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:title/>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:title' do |tag|
    tag.locals.post[:title]
  end

  desc %{
    Renders the url of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <a href="<r:url/>">view comments</a>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:url' do |tag|
    tag.locals.post[:link]
  end

  desc %{
    Renders the publish date of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:published_on [format="%A, %B %d, %Y"]/>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:published_on' do |tag|
    format = tag.attr['format'] || "%A, %B %d, %Y";
    tag.locals.post[:published_on].strftime(format)
  end

  desc %{
    Renders the author's name of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:author_name />
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:author_name' do |tag|
    tag.locals.post[:author][:name]
  end

  desc %{
    Renders the author's email address of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:author_email />
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:author_email' do |tag|
    tag.locals.post[:author][:email]
  end

  desc %{
    Renders the author's URI of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <r:author_uri />
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:author_uri' do |tag|
    tag.locals.post[:author][:uri]
  end

  desc %{
    Renders the post comment url of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <a href="<r:post_comment_url/>">add a comment</a>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:post_comment_url' do |tag|
    tag.locals.post[:post_comment_link]    
  end

    desc %{
    Renders the post comment url of a blog post. 

    *Usage:*
    
    <pre><code><r:blog url="http://myblog.blogspot.com">
      <r:posts:each>
        <r:post>
          <a href="<r:post_comment_url/>">add a comment</a>
        </r:post>
      </r:posts:each>
    </r:blog></code></pre>
  }
  tag 'blog:post:num_comments' do |tag|
    tag.locals.post[:comment_count]    
  end

end
