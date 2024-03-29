module ApplicationHelper

  def icon_tag(html_class)
    "<i class=\"#{html_class}\"></i>".html_safe
  end
  
  def gravatar_for user, options = {}
      email = user.email
      options = {:alt => 'avatar', :class => 'avatar', :size => 50}.merge! options
      id = Digest::MD5::hexdigest email.strip.downcase
      url = 'http://www.gravatar.com/avatar/' + id + '.jpg?s=' + options[:size].to_s + '&d=' + asset_path('avatar_placeholder_large.png')
      options.delete :size
      image_tag url, options
  end
  
  def avatar_for user, options = {}
    if user.avatar.present?
      image_tag user.avatar.thumb.url, options
    else
      gravatar_for user, options
    end
  end

  def bio_pic_for user, options = {}
    if user.bio_pic.present?
      image_tag user.bio_pic.url, options
    elsif user.avatar.present?
      image_tag user.avatar.url, options
    else
      gravatar_for user, options
    end
  end

  def sticker_for user, options = {}
    link_check = link_to_person(user.name, user)
    avatar_check = avatar_for(user)

    unless link_check.nil? || avatar_check.nil?
      options[:class] ||= ""
      if options[:link]
        link_to user do
          image_tag user.sticker_url, options
        end
      else
        image_tag user.sticker_url, options
      end
    end
  end
  
  def star_rating(score, max_score)
    content_tag :div, { id: 'star_ratings' } do
      stars = Array.new
      score.times { stars << content_tag(:i, nil, :class => "icon-star", :style => "color: black;") }
      (max_score - score).times { stars << content_tag(:i, nil, :class => "icon-star-empty", :style => "color: black;") }
      stars.join.html_safe
      # content_tag(:i, nil, :class => "icon-star", :style => "color: black;") +
      # content_tag(:i, nil, :class => "icon-star-empty", :style => "color: black;")
    end
  end

  def status_icon(condition)
    if condition
      content_tag :i, nil, :class => "icon-ok", :style => "color: green;"
    else
      content_tag :i, nil, :class => "icon-remove", :style => "color: red;"
    end      
  end

  def file_icon(extension, size = 'small', options = {})
    image_tag asset_path("file_icons/32px/#{extension}.png"), options
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
  
  def date_picker(object_name, method, options = {}, html_options = {})
    date = (options[:value]) ? options[:value] : Date.today
    html = <<-EOF
    <div class="input-append date datepicker" id="dp3" data-date="#{l date}" data-date-format="yyyy-mm-dd">
      <input name="#{object_name}[#{method}]" class="span2" size="16" type="text" value="#{l date}">
      <span class="add-on"><i class="icon-th"></i></span>
    </div>
    EOF
    html.html_safe
  end
end
