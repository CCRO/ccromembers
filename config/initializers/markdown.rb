class DocumentHTML < Redcarpet::Render::HTML
  def header(text, level)
    "<h#{level}><a name=\"#{text.parameterize}\" class=\"section-anchor\">.</a>#{text}</h#{level}>"
  end
end
