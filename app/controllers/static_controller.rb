class StaticController < ApplicationController
  before_filter :require_user, only: [:secret]
  layout 'blank', :except => 'unsupported_browser'
  layout 'static', :only => ['unsupported_browser', 'summit']
  
  def noscript
    render :layout => 'blank'
  end
  
  def unsupported_browser
  end

  def summit
  end
end
