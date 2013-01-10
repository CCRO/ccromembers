class StaticController < ApplicationController
  before_filter :require_user, only: [:secret]
  layout 'blank', :except => ['unsupported_browser', 'welcome']
  layout 'static', :only => ['unsupported_browser', 'summit']
  layout 'application', only: 'welcome'
  
  def noscript
    render :layout => 'blank'
  end
  
  def unsupported_browser
  end

  def summit
  end

  def welcome
    
    
    respond_to do |format|
      format.html
    end
  end
end
