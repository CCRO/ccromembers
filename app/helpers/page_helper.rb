module PageHelper
  def page_publish_toggle(object) 
      html = "<div class=\"btn-group\">"
  		html += link_to "Published", publish_page_path(object, :published=> false ), {:class =>'btn btn-success'} if object.published?
  		html += link_to "Published", publish_page_path(object, :published=> true ), {:class =>'btn disabled'} unless object.published?
      html += link_to "Draft", publish_page_path(object, :published=> false ), {:class =>'btn disabled'} if object.published?
      html += link_to "Draft", publish_page_path(object, :published=> true ), {:class =>'btn btn-danger'} unless object.published?
      html += "</div>"
      html.html_safe
  end

  def short_date(page)
    page_date = page.published_at if page.published
    page_date ||= page.updated_at
  	 if page_date.to_date == Time.now.to_date
  		l page_date, :format => :time
  	else
  		l page_date.to_date, :format => :short
  	end
  end

  def editor_selector(page)
    html = form_for page, { :remote => true } do |f|
      Person.editors.map { |editor| [editor.name, editor.id] }
      html += f.select(:author_id, options_for_select(editors))
    end
    html
  end
end

