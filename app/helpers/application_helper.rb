module ApplicationHelper

  def make_bold s
    s.gsub!('((', '<strong>')
    s.gsub!('))', '</strong>')
    s.html_safe
  end

  def get_speed
    if user_signed_in?
      return current_user.default_speed
    else
      unless session[:default_speed].present?
        session[:default_speed] = 3
      end
    end
    session[:default_speed].to_i
  end
end
