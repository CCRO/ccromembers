module DocumentsHelper
  def render_body(obj)
    case obj.format
    when "markdown"
      markdown = Redcarpet::Markdown.new(DocumentHTML,
              :autolink => true, :space_after_headers => true)
      markdown.render(obj.body).html_safe
    when "wikitext"
      wikitext = Wiky::Wikitext.new(CCROHTML)
      wikitext.process(obj.body).html_safe
    else
      obj.body.html_safe
    end
  end
end
