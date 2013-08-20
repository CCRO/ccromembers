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
  	caller_phone = params['From'].to_s[2..-1]
    called_phone = params['To'].to_s[2..-1]
    if Group.find_by_conf_phone(called_phone)
      @group = Group.find_by_conf_phone(called_phone)
      conf_room = @group.name.parameterize
    else
      conf_room = "ccro-conference-room"
    end

  	twiml = Twilio::TwiML::Response.new do |r|
  		if Person.find_by_mobile_phone(caller_phone)
  			@person = Person.find_by_mobile_phone(caller_phone)
  			r.Say "hello #{@person.name}! You will be placed into the #{@group.try(:name) if @group} conference room.", :voice => 'woman'
        r.Dial do
          r.Conference conf_room
        end
      elsif caller_phone == '2818254871'
        r.Say "Entering #{@group.try(:name) if @group} conference room as host.", :voice => 'woman'
        r.Dial  :record => 'true' do
          r.Conference conf_room, :beep => 'false', :waitUrl => ''
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
            r.Say "hello #{@person.name}! You will be placed into the #{@group.try(:name)  if @group} conference room.", :voice => 'woman'
            r.Dial do
              r.Conference conf_room
            end
          elsif params['Digits'] == '7100'
            r.Say "hello Guest! You will be placed into the #{@group.try(:name)  if @group} conference room.", :voice => 'woman'
            r.Dial do
              r.Conference conf_room
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
