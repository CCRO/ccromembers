module PeopleHelper

  def last_browser_info_for_person(person)
    if person.browser_info[:name].present? && person.browser_info[:platform].present?
      person.browser_info[:name] + ' - ' + person.browser_info[:platform].capitalize
    end
  end
end
