class StaticController < ApplicationController
  before_filter :require_user, only: [:secret]
  layout 'blank'
  
  def noscript
    render :layout => 'blank'
  end
  
end
