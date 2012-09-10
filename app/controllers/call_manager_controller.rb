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
  			r.Say "hello #{@person.name}! You will be placed into the coference.", :voice => 'woman'
        r.Dial do
          r.Conference "700"
        end
		  else 
        unless params['Digits']
    			r.Say 'You are calling from an unknown number.', :voice => 'woman'
          r.Gather :numDigits => 4 do
            r.Say "Please enter your PIN number", :voice => 'woman'
          end
        else
          if Person.find_by_pin_code(params['Digits'])
            @person = Person.find_by_pin_code(params['Digits'])
            r.Say "hello #{@person.name}! You will be placed into the coference.", :voice => 'woman'
            r.Dial do
              r.Conference "700"
            end
          else
            r.Say "Unknown PIN. Goodbye.", :voice => 'woman' 
          end 
        end  
      end      
		end

	response.last_modified = Time.now
	response.etag = twiml
	# print the result
	render :text => twiml.text
  end
end
