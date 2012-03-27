class CCROHTML < Wiky::Render::HTML
  def self.process_header(level, text)
    level += 1
    "<h#{level}><a name=\"#{text.parameterize}\" class=\"section-anchor\">.</a>#{text}</h#{level}>"
  end
end
