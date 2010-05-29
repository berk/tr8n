class Tr8n::Admin::TranslationController < Tr8n::Admin::BaseController

  def index
    @model_filter = init_model_filter(Tr8n::TranslationFilter)
    @translations = Tr8n::Translation.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def view
    @translation = Tr8n::Translation.find(params[:translation_id])
    @votes = Tr8n::TranslationVote.find(:all, :conditions => ["translation_id = ?", @translation.id], :order => "created_at desc", :limit => 20)
  end

  def delete
    translation = Tr8n::Translation.find_by_id(params[:translation_id]) if params[:translation_id]
    translation.destroy if translation
    
    if params[:source] == "translation"
      redirect_to(:action => :index)
    else
      redirect_to_source  
    end
  end

  def votes
    @model_filter = init_model_filter(Tr8n::TranslationVoteFilter)
    @votes = Tr8n::TranslationVote.paginate(:order=>@model_filter.order_clause, :page=>page, :per_page=>@model_filter.per_page, :conditions=>@model_filter.sql_conditions)
  end

  def delete_vote
    vote = Tr8n::TranslationVote.find(params[:vote_id])
    translation = vote.translation
    vote.destroy
    
    translation.reload
    translation.update_rank!
    redirect_to_source
  end
end
