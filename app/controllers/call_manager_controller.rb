class CallManagerController < ApplicationController

layout 'twiml'

  def sms
  	if Person.find_by_pin_code(params['Body'].upcase)
  		@user = Person.find_by_pin_code(params['Body'].upcase)
  		@user.mobile_phone = params['From']
  		@user.save
	  	response = Twilio::TwiML::Response.new do |r|
		  r.Sms "Thank you, #{@user.name}! You are now verified. To unsubscribe from the CCRO reply STOP."
		end
	else
	  	response = Twilio::TwiML::Response.new do |r|
		  r.Sms 'Unknown PIN.'
		end
	end		

	# print the result
	render :text => response.text
  end

  def voice
  	twiml = Twilio::TwiML::Response.new do |r|
  		if Person.find_by_mobile_phone(params['Caller'])
  			@person = Person.find_by_mobile_phone(params['Caller'])
			r.Say "hello #{@person.name}!", :voice => 'woman'
		else 
			r.Say 'You are calling from an unknown number.', :voice => 'woman'
		end
	end

	response.last_modified = Time.now
	response.etag = twiml
	# print the result
	render :text => twiml.text
  end
end
