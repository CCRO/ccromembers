class DocumentHTML < Redcarpet::Render::HTML
  def header(text, level)
    level += 1
    "<h#{level}><a name=\"#{text.parameterize}\" class=\"section-anchor\">.</a>#{text}</h#{level}>"
  end
end
