class Admin::AdminsController < Admin::BaseController
  
  def index
    @admins = Admin.filter(:params => params, :filter => AdminFilter)
  end

end
