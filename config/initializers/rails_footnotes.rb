if defined?(Footnotes) && Rails.env.development?

  Footnotes.setup do |config|
    config.before do |controller, filter|
      if controller.action_name == 'sms' || controller.action_name == 'voice' #  any conditions
        controller.params[:footnotes] = "false" # disable footnotes
      end
    end
  end

  Footnotes.run!

  # ... other init code
end