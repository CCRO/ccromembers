module Blog::PostHelper
  def publish_toggle(object) 
      html = "<div class=\"btn-group\">"
  		html += link_to "Published", publish_blog_post_path(object, :published=> false ), {:class =>'btn btn-success'} if object.published?
  		html += link_to "Published", publish_blog_post_path(object, :published=> true ), {:class =>'btn disabled'} unless object.published?
      html += link_to "Draft", publish_blog_post_path(object, :published=> false ), {:class =>'btn disabled'} if object.published?
      html += link_to "Draft", publish_blog_post_path(object, :published=> true ), {:class =>'btn btn-danger'} unless object.published?
      html += "</div>"
      html.html_safe
  end
end
