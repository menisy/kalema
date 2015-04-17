class UsersController < ApplicationController

  def change_local
    local = params[:local]
    if user_signed_in?
      current_user.default_local = local
      current_user.save
    else
      session[:local] = local
    end

    session.delete(:first)

    I18n.locale = local.to_sym
    redirect_to :back, notice: I18n.t(:language_set)
  end

  def set_speed
    speed = params[:data].to_i
    if user_signed_in?
      current_user.default_speed = speed
      current_user.save
    else
      session[:default_speed] = speed
    end
  end
end
