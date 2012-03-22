module ApplicationHelper
  def render_body(obj)
    case obj.format
    when "markdown"
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
              :autolink => true, :space_after_headers => true)
      markdown.render(obj.body).html_safe
    when "wikitext"
      Wiky.process(obj.body).html_safe
    else
      obj.body
    end
  end
  
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
    html.html_safe
  end
  
  def gravatar_for user, options = {}
      email = user.email
      options = {:alt => 'avatar', :class => 'avatar', :size => 160}.merge! options
      id = Digest::MD5::hexdigest email.strip.downcase
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?s=' + options[:size].to_s
      options.delete :size
      image_tag url, options
  end
  
  def button_to(*args, &block)
    if args[2] && args[2][:class]
      args[2][:class] = 'btn ' + args[2][:class]
    else
      args[2] = {:class => 'btn'}
    end
    link_to(*args, &block)
  end
  
  def link_to_person(*args, &block)
    args[2] = {:remote => true, :rel => 'modal-person', 'data-controls-modal' =>  "modal-window", 'data-backdrop' => true, 'data-keyboard' => true}
    link_to(*args, &block)
  end
  
  def highrise_url(obj)
    "https://ccro.highrisehq.com/#{obj.class.name.pluralize.downcase}/" + obj.highrise_id if obj.highrise_id
  end
  
  def freshbooks_url(obj)
    'https://ccro.freshbooks.com/clients/' + obj.freshbooks_id if obj.freshbooks_id
  end
end
