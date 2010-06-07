class Tr8n::TranslationsController < Tr8n::BaseController

  before_filter :validate_current_translator
  before_filter :validate_default_language, :except => [:translate, :vote]
  
  # main translation method used by the translator and translation screens
  def translate
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translations = @translation_key.translations_for(tr8n_current_language)
    @source_url = params[:source_url] || request.env['HTTP_REFERER']
    
    unless request.post?
      trfe("Please use a translator window for submitting translations")
      return redirect_to(@source_url)
    end

    if params[:translation_has_dependencies] == "true" # comes from inline translator only
      @translation_key.generate_rule_permutations(tr8n_current_language, tr8n_current_translator, params[:dependencies])
      trfn("We have created all possible combinations of the values for the tokens. Please provide a translation for each combination.")
      return redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => @translation_key.id, :submitted_by => :me, :submitted_on => :today)
    end
    
    if params[:translation_id].blank?
      @translation = Tr8n::Translation.new(:translation_key => @translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    else  
      @translation = Tr8n::Translation.find(params[:translation_id])
    end
    
    @translation.label = sanitize_label(params[:translation][:label])
    @translation.rules = parse_rules
    
    unless @translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation which is locked or belongs to another translator")
      trfe("You are not authorized to edit this translation")
      return redirect_to(@source_url)
    end  
    
    unless @translation.clean?
      tr8n_current_translator.used_abusive_language!
      trfe("Your translation contains prohibited words and will not be accepted")
      return redirect_to(@source_url)
    end

    @translation.save_with_log!(tr8n_current_translator)
    @translation.reset_votes!(tr8n_current_translator)

    redirect_to(@source_url)
  end
  
  def vote
    @translation = Tr8n::Translation.find(params[:translation_id])
    @translation.vote!(tr8n_current_translator, params[:vote])
    @translation_key = @translation.translation_key

    # this is called from page translations page
    if params[:short_version]
      return render(:text => @translation.rank_label) 
    end
    
    # this is called from the inline translator with reordering the translations based on ranks
    @translations = @translation_key.inline_translations_for(tr8n_current_language)
    render(:partial => '/tr8n/common/translation_votes', :locals => {:translation_key => @translation_key, :translations => @translations, :section_key => ""})
  end
    
  def index
    conditions = Tr8n::Translation.search_conditions_for(params)
    @translations = Tr8n::Translation.paginate(:per_page => per_page, :page => page, :conditions => conditions, :order => "created_at desc, rank desc")    
  end

  #  ajax based method for updating individual translations
  def update
    @translation = Tr8n::Translation.find(params[:translation_id])
    mode = params[:mode] || :view
    
    if request.post?
      mode = :view
      unless params[:label].strip.blank?
        @translation.label = sanitize_label(params[:label])
        
        unless @translation.can_be_edited_by?(tr8n_current_translator)
          tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation that is not his")
          @translation.label = "You are not authorized to edit this translation as you were not it's creator"
          mode = :edit
        else  
          if @translation.clean?
            @translation.save_with_log!(tr8n_current_translator)
            @translation.reset_votes!(tr8n_current_translator)
          else
            tr8n_current_translator.used_abusive_language!
            @translation.label = "Your translation contains prohibited words and will not be accepted. Click on cancel and try again."
            mode = :edit
          end
        end

      end
    end
    render(:partial => "translation", :locals => {:language => tr8n_current_language, :translation => @translation, :mode => mode.to_sym})
  end  
  
  def delete
    translation = Tr8n::Translation.find(params[:translation_id])
    translator = translation.translator

    unless translation.can_be_deleted_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to delete translation that is not his")
      trfe("You are not authorized to delete this translation as you were not it's creator")
    else
      translation.destroy_with_log!(tr8n_current_translator)
      translator.update_rank!
      trfn("Your translation has been removed.")
    end
    
    redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => translation.translation_key.id, :section_key => @section_key)
  end
    
private

  def parse_rules
    return nil unless params[:has_rules] == "true" and params[:rules] 
    
    rulz = []
    params[:rules].keys.each do |token|
      next unless params[:rules][token][:selected] == "true" 
      rulz << {:token => token, :rule_id => params[:rules][token][:rule_id]}
    end
    rulz
  end

end