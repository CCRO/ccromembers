class CanAccessRoute
  def self.matches?(request)
    current_user = Person.find(request.env["rack.session"]["user_id"]) if request.env["rack.session"]["user_id"]
    current_ability = Ability.new(current_user)
    current_ability.can? :route, :delayed_job
  end
end