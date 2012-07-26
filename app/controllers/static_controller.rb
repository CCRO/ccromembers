class StaticController < ApplicationController
  before_filter :require_user, only: [:secret]
  layout 'blank', :except => 'unsupported_browser'
  layout 'static', :only => 'unsupported_browser'
  
  def noscript
    render :layout => 'blank'
  end
  
  def unsupported_browser
  end
end
