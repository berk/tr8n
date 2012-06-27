# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

  def display_user_tag(user)
    "#{user.name} (#{user.id})"
  end

end
