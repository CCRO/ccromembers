Rails.configuration.to_prepare do
  Impression.class_eval do
    def person
      Person.find(self.user_id) if self.user_id
    end
  end
end