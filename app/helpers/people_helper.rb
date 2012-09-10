module PeopleHelper

  def last_browser_info_for_person(person)
    if person.last_browser.present? && person.last_platform.present?
      person.last_browser + ' - ' + person.last_platform.capitalize
    end
  end
end
