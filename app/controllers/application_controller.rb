class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_local

  def set_local
    local = :ar
    if user_signed_in?
      local = current_user.default_local.to_sym
    else
      local = session[:local].to_sym if session[:local]
    end
    I18n.locale = local
  end
end
