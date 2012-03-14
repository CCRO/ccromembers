module ApplicationHelper
  def markdown(text)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
            :autolink => true, :space_after_headers => true)
    markdown.render(text).html_safe
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
