class DebugController < ApplicationController
  
  layout 'blank'
  
  def diagnostics
    @session = session
    @current_user = current_user
    @params = params
    @request = request   
  end
end
