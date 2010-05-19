class Tr8n::Admin::TranslatorController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslatorFilter)
    @translators = Tr8n::Translator.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @translator = Tr8n::Translator.find(params[:translator_id])
  end

  def block
    @translator = Tr8n::Translator.find(params[:translator_id])
    @translator.block!(tr8n_current_user, params[:reason])
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def unblock
    @translator = Tr8n::Translator.find(params[:translator_id])    
    @translator.unblock!(tr8n_current_user, params[:reason])
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def promote
    @translator = Tr8n::Translator.find(params[:translator_id])
    language = Tr8n::Language.find(params[:language_id])
    @translator.promote!(tr8n_current_user, language, params[:reason])
    redirect_to :action => :view, :translator_id => @translator.id
  end

  def demote
    @translator = Tr8n::Translator.find(params[:translator_id])
    language = Tr8n::Language.find(params[:language_id])
    @translator.demote!(tr8n_current_user, language, params[:reason])
    redirect_to :action => :view, :translator_id => @translator.id
  end
  
  def update_stats
    Tr8n::Translator.all.each do |trans|
      trans.update_total_metrics!
    end
  
    redirect_to :action => :index
  end
   
end
