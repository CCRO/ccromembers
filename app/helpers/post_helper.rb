module PostHelper
  def publish_toggle(object) 
      html = "<div class=\"btn-group\">"
  		html += link_to "Published", polymorphic_path([object.owner, object], :action => 'publish', :published=> false ), {:class =>'btn btn-success'} if object.published?
  		html += link_to "Published", polymorphic_path([object.owner, object], :action => 'publish', :published=> true ), {:class =>'btn disabled'} unless object.published?
      html += link_to "Draft", polymorphic_path([object.owner, object], :action => 'publish', :published=> false ), {:class =>'btn disabled'} if object.published?
      html += link_to "Draft", polymorphic_path([object.owner, object], :action => 'publish', :published=> true ), {:class =>'btn btn-danger'} unless object.published?
      html += "</div>"
      html.html_safe
  end

  def short_date(post)
    post_date = post.published_at if post.published
    post_date ||= post.updated_at
  	 if post_date.to_date == Time.now.to_date
  		l post_date, :format => :time
  	else
  		l post_date.to_date, :format => :short
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
