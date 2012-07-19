module PostHelper
  def publish_toggle(object) 
      html = "<div class=\"btn-group\">"
  		html += link_to "Published", publish_post_path(object, :published=> false ), {:class =>'btn btn-success'} if object.published?
  		html += link_to "Published", publish_post_path(object, :published=> true ), {:class =>'btn disabled'} unless object.published?
      html += link_to "Draft", publish_post_path(object, :published=> false ), {:class =>'btn disabled'} if object.published?
      html += link_to "Draft", publish_post_path(object, :published=> true ), {:class =>'btn btn-danger'} unless object.published?
      html += "</div>"
      html.html_safe
  end

  def short_date(post)
  	 if post.created_at.to_date == Time.now.to_date
  		l post.created_at, :format => :time
  	else
  		l post.created_at.to_date, :format => :short
  	end
  end

  def editor_selector(post)
    html = form_for post, { :remote => true } do |f|
      Person.editors.map { |editor| [editor.name, editor.id] }
      html += f.select(:author_id, options_for_select(editors))
    end
    html
  end
end
