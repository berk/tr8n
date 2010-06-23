class Tr8n::Admin::TranslatorController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslatorFilter)
    @translators = Tr8n::Translator.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @translator = Tr8n::Translator.find(params[:translator_id])
  end

  def delete
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.destroy
    trfn("Translator has been deleted")
    redirect_to :action => :index
  end

  def block
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.block!(tr8n_current_user, params[:reason])
    trfn("Translator has been blocked")
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def unblock
    @translator = Tr8n::Translator.find(params[:translator_id])    
    @translator.unblock!(tr8n_current_user, params[:reason])
    trfn("Translator has been unblocked")
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def promote
    @translator = Tr8n::Translator.find(params[:translator_id])
    language = Tr8n::Language.find(params[:language_id])
    @translator.promote!(tr8n_current_user, language, params[:reason])
    trfn("Translator has been promoted to be a manager of #{language.english_name} language")
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def demote
    @translator = Tr8n::Translator.find(params[:translator_id])
    language = Tr8n::Language.find(params[:language_id])
    @translator.demote!(tr8n_current_user, language, params[:reason])
    trfn("Translator has been demoted from managing #{language.english_name} language")
    redirect_to :action => :view, :translator_id => @translator.id
  end
  
  def update_stats
    Tr8n::Translator.all.each do |trans|
      trans.update_total_metrics!
    end
  
    redirect_to :action => :index
  end
   
  def lb_register
    @translator = Tr8n::Translator.new    
    render :layout => false
  end

  def register
    user_class = Tr8n::Config.site_info[:user_info][:class_name]
    user = user_class.constantize.find_by_id(params[:translator][:user_id])
    unless user
      trfe("#{user_class} not found")
      return redirect_to_source
    end
    
    translator = Tr8n::Translator.find_by_user_id(user.id)
    if translator
      trfe("#{user_class} is already a translator ")
      return redirect_to_source
    end
    
    Tr8n::Translator.create(:user_id => params[:translator][:user_id])
    trfn("#{user_class} has been registered as a translator ")
    redirect_to_source
  end
   
  def log
    @model_filter = init_model_filter(Tr8n::TranslatorLogFilter)
    @logs = Tr8n::TranslatorLog.paginate(:order => @model_filter.order_clause, :page => page, :per_page => @model_filter.per_page, :conditions => @model_filter.sql_conditions)
  end

  def metrics
    @model_filter = init_model_filter(Tr8n::TranslatorMetricFilter)
    @metrics = Tr8n::TranslatorMetric.paginate(:order => @model_filter.order_clause, :page => page, :per_page => @model_filter.per_page, :conditions => @model_filter.sql_conditions)
  end
     
end
