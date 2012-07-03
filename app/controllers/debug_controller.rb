class DebugController < ApplicationController
  
  layout 'blank'
  
  def diagnostics
    @session = session
    @current_user = current_user
    @params = params
    @request = request   
  end

  def test
  	# AdminMailer.signup_complete(Person.last, "http://example.com/blah").deliver
  end
end
