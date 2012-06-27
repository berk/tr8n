class Admin::BaseController < ApplicationController
  before_filter :verify_admin_user

  layout 'admin'

private

  def verify_admin_user
    redirect_to("/home") unless current_user.admin?
  end
  
end
