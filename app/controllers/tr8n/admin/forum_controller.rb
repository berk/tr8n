class Tr8n::Admin::ForumController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter("Tr8n::LanguageForumMessage")
    @messages = Tr8n::LanguageForumMessage.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def delete
    message = Tr8n::LanguageForumMessage.find_by_id(params[:msg_id]) if params[:msg_id]
    message.destroy if message

    redirect_to_source
  end  
    
end
