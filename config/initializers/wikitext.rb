class CCROHTML < Wiky::Render::HTML
  def self.process_header(level, text)
    "<h#{level} id=\"#{text.parameterize}\">#{text}</h#{level}>"
  end
end
