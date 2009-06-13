# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class BloggerExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/blogger"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :blogger
  #   end
  # end
  
  def activate
    Page.send :include, BloggerTags
    # admin.tabs.add "Blogger", "/admin/blogger", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Blogger"
  end
  
end
