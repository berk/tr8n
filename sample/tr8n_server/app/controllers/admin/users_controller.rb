class Admin::UsersController < Admin::BaseController
  
  def index
    @users = User.filter(:params => params)
  end

  def promote
    user = User.find_by_id(params[:user_id])
    user.make_admin! if user
    redirect_to_source
  end

  def demote
    user = User.find_by_id(params[:user_id])
    user.admin.destroy if user and user.admin?
    redirect_to_source
  end

end
